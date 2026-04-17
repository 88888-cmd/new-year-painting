<template>
    <div>
        <el-card class="form-container" shadow="never">
            <aside style="margin-bottom: 20px">添加运费模板</aside>

            <el-form label-width="100px" size="medium">
                <el-form-item label="规则名称">
                    <el-input v-model="form.name" maxlength="100" placeholder="请输入规则名称"></el-input>
                </el-form-item>

                <el-form-item label="配送区域规则">
                    <el-table style="width: 100%" :data="form.regions" border>

                        <el-table-column label="配送区域" align="center">
                            <template slot-scope="scope">
                                <el-input v-model="scope.row.region_name" placeholder="选择配送区域" size="small"
                                    @click.native="scope.$index !== 0 && handleRegionSelect(scope.$index)"
                                    style="width: 100%"></el-input>
                            </template>
                        </el-table-column>

                        <el-table-column label="首件数量" align="center">
                            <template slot-scope="scope">
                                <el-input-number size="small" v-model="scope.row.first" :precision="0" :step="1"
                                    :min="0" :max="99999999" style="width: 100%"></el-input-number>
                            </template>
                        </el-table-column>

                        <el-table-column label="首件运费" align="center">
                            <template slot-scope="scope">
                                <el-input-number size="small" v-model="scope.row.first_price" :precision="2"
                                    :step="0.01" :min="0" :max="99999999.99" style="width: 100%"></el-input-number>
                            </template>
                        </el-table-column>

                        <el-table-column label="续件数量" align="center">
                            <template slot-scope="scope">
                                <el-input-number size="small" v-model="scope.row.continue_num" :precision="0" :step="1"
                                    :min="0" :max="99999999" style="width: 100%"></el-input-number>
                            </template>
                        </el-table-column>

                        <el-table-column label="续件运费" align="center">
                            <template slot-scope="scope">
                                <el-input-number size="small" v-model="scope.row.continue_price" :precision="2"
                                    :step="0.01" :min="0" :max="99999999.99" style="width: 100%"></el-input-number>
                            </template>
                        </el-table-column>

                        <el-table-column width="100" align="center">
                            <template slot="header">
                                <el-button size="mini" type="primary" @click="addRegion">添加</el-button>
                            </template>
                            <template slot-scope="scope">
                                <el-button size="mini" type="danger" @click="removeRegion(scope.$index)"
                                    :disabled="scope.$index === 0">删除</el-button>
                            </template>
                        </el-table-column>
                    </el-table>
                </el-form-item>


                <el-form-item style="text-align: center; margin-top: 20px">
                    <el-button type="primary" @click="clickSubmit">提交</el-button>
                </el-form-item>
            </el-form>
        </el-card>

        <el-dialog title="选择配送区域" :visible.sync="regionDialogVisible" width="50%" @close="clearSelectedRegions">
            <div class="region-selector">
                <el-cascader v-model="selectedRegions" :options="regionOptions" size="medium"
                    style="width: 100%"></el-cascader>
            </div>
            <template #footer>
                <el-button @click="regionDialogVisible = false">取消</el-button>
                <el-button type="primary" @click="confirmRegionSelection">确定</el-button>
            </template>
        </el-dialog>
    </div>
</template>

<script>
import { detail, edit } from '@/api/freightTemp';
import regionData from '@/assets/json/region.json';
export default {
    data() {
        return {
            form: {
                name: '',
                regions: []
            },
            allRegions: regionData,
            allProvinces: [],
            regionDialogVisible: false,
            selectedRegions: [],
            currentRegionIndex: -1,
            regionOptions: [],


            disabled: false,
        };
    },
    created() {
        this.allProvinces = this.allRegions.filter(region => region.type === 0);
        this.initRegionOptions();
        this.fetchData();
    },
    methods: {
        async fetchData() {
            this.disabled = true;

            try {
                const detailResult = await detail(this.$route.params.id);
                for (let key in detailResult.data) {
                    if (this.form.hasOwnProperty(key)) {
                        this.form[key] = detailResult.data[key];
                    }
                }

                this.disabled = false;
            } catch (e) {

            }
        },
        initRegionOptions() {
            this.regionOptions = this.allProvinces.map(province => {
                const cities = this.allRegions
                    .filter(region => region.type === 1 && region.parent_code === province.code)
                    .map(city => ({
                        value: city.code,
                        label: city.name
                    }));

                return {
                    value: province.code,
                    label: province.name,
                    children: cities
                };
            });
            console.log(this.regionOptions)
        },
        addRegion() {
            this.form.regions.push({
                region_name: '',
                is_default: 0,
                province_code: '',
                city_code: '',
                first: 0,
                first_price: 0,
                continue_num: 0,
                continue_price: 0
            });
        },
        removeRegion(index) {
            if (index === 0) return;
            this.form.regions.splice(index, 1);
        },
        handleRegionSelect(index) {
            this.currentRegionIndex = index;
            this.regionDialogVisible = true;

            const region = this.form.regions[index];
            if (region.province_code) {
                this.selectedRegions = region.city_code
                    ? [region.province_code, region.city_code]
                    : [region.province_code];
            }
        },
        confirmRegionSelection() {
            if (this.selectedRegions.length === 0) return;

            const region = this.form.regions[this.currentRegionIndex];
            const selectedCodes = [...this.selectedRegions];

            region.province_code = selectedCodes[0];
            region.city_code = selectedCodes.length > 1 ? selectedCodes[1] : '';

            const province = this.allRegions.find(r => r.code === selectedCodes[0]);
            let regionName = province ? province.name : '';

            if (selectedCodes.length > 1) {
                const city = this.allRegions.find(r => r.code === selectedCodes[1]);
                regionName += city ? `-${city.name}` : '';
            }

            region.region_name = regionName;
            this.regionDialogVisible = false;
        },
        clearSelectedRegions() {
            this.selectedRegions = [];
            this.currentRegionIndex = -1;
        },
        clickSubmit() {
            if (this.disabled) return;
            this.disabled = true;

            const submitData = {
                ...this.form,
                // regions: this.form.regions.map(region => ({
                //     region_name: region.region_name,
                //     is_default: region.is_default,
                //     province_codes: region.province_code,
                //     city_codes: region.city_code,
                //     first: region.first,
                //     first_price: region.first_price,
                //     continue_num: region.continue_num,
                //     continue_price: region.continue_price
                // }))
                // regions: this.form.regions.map(region => ({
                //     ...region,
                //     province_codes: region.province_code,
                //     city_codes: region.city_code
                // }))
            };

            if (!submitData.name) {
                this.$message.error('请输入规则名称');
                this.disabled = false;
                return;
            }

            if (submitData.regions.length === 0) {
                this.$message.error('至少需要一个配送区域规则');
                this.disabled = false;
                return;
            }

            edit({ temp_id: this.$route.params.id, ...this.form })
                .then((response) => {
                    this.$message({
                        message: "编辑成功",
                        type: "success",
                    });
                    this.$router.push({ path: "/setting/freightTemp" });
                })
                .finally(() => {
                    this.disabled = false;
                });
        }
    }
};
</script>

<style scoped>
.form-container {
    width: 80%;
}

.region-selector {
    padding: 10px;
}
</style>