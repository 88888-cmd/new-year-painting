<template>
    <div>
        <el-card class="form-container" shadow="never">
            <aside style="margin-bottom: 20px">积分设置</aside>
            <el-form label-width="160px" size="medium">
                <el-form-item label="每笔订单赠送积分">
                    <el-input-number v-model="form.order_fixed_points" :precision="0" :step="1" :min="0" :max="99999999"
                        style="width: 100%"></el-input-number>
                    <div style="color: #909399; font-size: 12px; margin-top: 5px;">
                        普通商城（app端-年画周边）下单平台赠送普通积分
                    </div>
                </el-form-item>
                <el-form-item label="每笔订单最多使用积分">
                    <el-input-number v-model="form.normal_points_max_num" :precision="0" :step="1" :min="0"
                        :max="99999999" style="width: 100%"></el-input-number>
                    <div style="color: #909399; font-size: 12px; margin-top: 5px;">
                        普通商城（app端-年画周边）订单最多可使用普通积分数
                    </div>
                </el-form-item>
                <el-form-item label="普通积分抵扣金额">
                    <el-input-number v-model="form.normal_points_per_yuan" :precision="2" :step="0.1" :min="0"
                        :max="99999999.99" style="width: 100%"></el-input-number>
                    <div style="color: #909399; font-size: 12px; margin-top: 5px;">
                        普通商城（app端-年画周边）下单积分抵扣金额(如 1积分 抵扣 0.01 金额)单位：元
                    </div>
                </el-form-item>
                <el-form-item style="text-align: center; margin-top: 20px">
                    <el-button :disabled="disabled" type="primary" @click="clickSubmit">提交</el-button>
                </el-form-item>
            </el-form>
        </el-card>
    </div>
</template>

<script>
import { getPointsConfig, setPointsConfig } from '@/api/setting';
export default {
    data() {
        return {
            form: {
                order_fixed_points: 0,
                normal_points_max_num: 0,
                normal_points_per_yuan: ''
            },
            disabled: false,
        };
    },
    created() {
        this.fetchData();
    },
    methods: {
        async fetchData() {
            this.disabled = true;
            try {
                const result = await getPointsConfig();
                for (let key in result.data) {
                    if (this.form.hasOwnProperty(key)) {
                        this.form[key] = result.data[key];
                    }
                }
                this.disabled = false;
            } catch (e) { }
        },
        clickSubmit() {
            if (this.disabled) return;
            if (typeof this.form.order_fixed_points != "number") {
                this.$message.error("请输入每笔订单赠送积分");
                return;
            }
            if (typeof this.form.normal_points_max_num != "number") {
                this.$message.error("请输入每笔订单最多使用积分");
                return;
            }
            if (typeof this.form.normal_points_per_yuan != "number") {
                this.$message.error("请输入普通积分抵扣金额");
                return;
            }

            this.disabled = true;

            setPointsConfig(this.form)
                .then((response) => {
                    this.$message({
                        message: "设置成功",
                        type: "success",
                    });
                })
                .finally(() => {
                    this.disabled = false;
                });
        },
    },
};
</script>
