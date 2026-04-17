<template>
    <div class="app-container">
        <el-button size="medium" type="primary" @click="openAddDialog()">添加</el-button>
        <el-table ref="multipleTable" v-loading="listLoading" :data="list" :height="tableHeight"
            element-loading-text="Loading" border fit highlight-current-row style="margin-top: 15px">
            <el-table-column label="ID" width="75" align="center">
                <template slot-scope="scope">
                    <span>{{ scope.row.id }}</span>
                </template>
            </el-table-column>
            <el-table-column label="日期" align="center">
                <template slot-scope="scope">
                    <span>{{ scope.row.date }}</span>
                </template>
            </el-table-column>
            <el-table-column label="节日名称" align="center">
                <template slot-scope="scope">
                    <span>{{ scope.row.festival_name }}</span>
                </template>
            </el-table-column>
            <el-table-column label="节日描述" align="center">
                <template slot-scope="scope">
                    <span>{{ scope.row.description || '无' }}</span>
                </template>
            </el-table-column>
            <el-table-column label="年画名称" align="center">
                <template slot-scope="scope">
                    <span>{{ scope.row.painting_name || '未关联' }}</span>
                </template>
            </el-table-column>
            <el-table-column label="添加时间" align="center">
                <template slot-scope="scope">
                    <i class="el-icon-time" />
                    <span>{{ scope.row.create_time }}</span>
                </template>
            </el-table-column>
            <el-table-column width="200" label="操作" align="center">
                <template slot-scope="scope">
                    <el-button size="mini" type="danger" icon="el-icon-delete"
                        @click="clickDelete(scope.row.id)">删除</el-button>
                </template>
            </el-table-column>
        </el-table>

        <el-dialog title="添加节日年画" width="50%" :visible.sync="dialogVisible">
            <el-form label-position="left" label-width="100px" size="medium" :model="form">
                <el-form-item label="日期" prop="date">
                    <el-date-picker v-model="form.date" type="date" placeholder="选择日期" style="width: 100%"
                        value-format="yyyy-MM-dd">
                    </el-date-picker>
                </el-form-item>
                <el-form-item label="节日名称" prop="festival_name">
                    <el-input v-model="form.festival_name" placeholder="请输入节日名称" maxlength="50"></el-input>
                </el-form-item>

                <el-form-item label="节日描述" prop="description">
                    <el-input type="textarea" v-model="form.description" placeholder="请输入节日描述" maxlength="200"
                        :rows="3"></el-input>
                </el-form-item>

                <el-form-item label="关联年画">
                    <el-radio-group v-model="isPaintingLimited">
                        <el-radio :label="true">选择年画</el-radio>
                        <el-radio :label="false">不关联年画</el-radio>
                    </el-radio-group>

                    <el-input v-model="selectedPaintingName" readonly
                        :placeholder="isPaintingLimited ? '请选择年画' : '不关联年画'" style="width: 80%; margin-top: 10px"
                        :disabled="!isPaintingLimited">
                        <template #append>
                            <el-button icon="el-icon-search" @click="isPaintingLimited && (paintingDialogVisible = true)"
                                :disabled="!isPaintingLimited">选择</el-button>
                        </template>
                    </el-input>
                </el-form-item>
            </el-form>

            <span slot="footer">
                <el-button size="medium" @click="dialogVisible = false">取消</el-button>
                <el-button type="primary" size="medium" @click="clickSubmit">确定</el-button>
            </span>
        </el-dialog>

        <el-dialog title="选择年画" :visible.sync="paintingDialogVisible" width="70%" :before-close="handleDialogClose">
            <el-table ref="paintingTable" :data="paintings" border fit highlight-current-row @row-click="handleRowClick"
                :row-class-name="tableRowClassName">
                <el-table-column label="选择" width="60" align="center">
                    <template slot-scope="scope">
                        <el-radio :label="scope.row.id" v-model="selectedPaintingId" class="custom-radio">
                            <span class="hidden-label"></span>
                        </el-radio>
                    </template>
                </el-table-column>
                <el-table-column label="ID" width="75" align="center">
                    <template slot-scope="scope">{{ scope.row.id }}</template>
                </el-table-column>
                <el-table-column label="图片" align="center">
                    <template slot-scope="scope">
                        <el-image style="width: 70px; height: 70px; vertical-align: middle" :src="scope.row.image_url"
                            fit="cover"></el-image>
                    </template>
                </el-table-column>
                <el-table-column label="名称" align="center">
                    <template slot-scope="scope">{{ scope.row.name }}</template>
                </el-table-column>
                <el-table-column label="添加时间" align="center">
                    <template slot-scope="scope">
                        <i class="el-icon-time"></i>
                        <span>{{ scope.row.create_time }}</span>
                    </template>
                </el-table-column>
            </el-table>
            <div slot="footer" class="dialog-footer">
                <el-button @click="paintingDialogVisible = false">取消</el-button>
                <el-button type="primary" @click="confirmPaintingSelection">确定</el-button>
            </div>
        </el-dialog>
    </div>
</template>

<script>
import { getList, add, del } from '@/api/paintingCalendar';
import { getList as getPaintingList } from '@/api/painting';

export default {
    data() {
        return {
            list: [],
            listLoading: false,
            tableHeight: window.innerHeight - 145,

            dialogVisible: false,
            paintingDialogVisible: false,
            form: {
                date: '',
                festival_name: '',
                description: '',
                painting_id: 0
            },
            paintings: [],
            selectedPaintingName: '',
            selectedPaintingId: 0,
            isPaintingLimited: false,
            disabled: false
        };
    },
    created() {
        this.fetchData();
        this.fetchPaintings();
    },
    watch: {
        isPaintingLimited(val) {
            if (!val) {
                this.selectedPaintingId = 0;
                this.selectedPaintingName = '';
                this.form.painting_id = 0;
            }
        }
    },
    methods: {
        fetchData() {
            this.listLoading = true;
            getList().then((response) => {
                this.list = response.data;
                this.listLoading = false;
            });
        },
        openAddDialog() {
            Object.assign(this.$data.form, this.$options.data().form);

            this.isPaintingLimited = false;
            this.selectedPaintingId = 0;
            this.selectedPaintingName = '';

            this.dialogVisible = true;
        },
        fetchPaintings() {
            getPaintingList().then(response => {
                this.paintings = response.data;
            });
        },
        handleRowClick(row) {
            this.selectedPaintingId = row.id;
            this.selectedPaintingName = row.name;
        },
        tableRowClassName({ row }) {
            return row.id === this.selectedPaintingId ? 'el-table__row--active' : '';
        },
        handleDialogClose(done) {
            if (this.isPaintingLimited && this.selectedPaintingId === 0) {
                this.$confirm('确定不选择年画吗？', '提示', {
                    confirmButtonText: '确定',
                    cancelButtonText: '取消',
                    type: 'warning'
                }).then(() => {
                    done();
                }).catch(() => {
                });
            } else {
                done();
            }
        },
        confirmPaintingSelection() {
            if (this.isPaintingLimited && this.selectedPaintingId === 0) {
                this.$message.warning('请选择一幅年画');
                return;
            }

            this.form.painting_id = this.selectedPaintingId;
            this.paintingDialogVisible = false;
        },
        clickSubmit() {
            if (!this.form.date) {
                this.$message.error("请选择日期");
                return;
            }
            if (!this.form.festival_name.length) {
                this.$message.error("请输入节日名称");
                return;
            }

            this.disabled = true;

            add(this.form).then(response => {
                this.$message({
                    message: "添加成功",
                    type: "success",
                });
                this.dialogVisible = false;
                this.fetchData();
            }).finally(() => {
                this.disabled = false;
            });
        },
        clickDelete(id) {
            let that = this;
            that
                .$confirm("确定删除吗?", "Prompt", {
                    confirmButtonText: "确认",
                    cancelButtonText: "取消",
                    type: "warning",
                })
                .then(() => {
                    del(id).then((response) => {

                        const index = this.list.findIndex(item => item.id == id);

                        if (index > -1) {
                            that.list.splice(index, 1);
                        }

                        that.$message({
                            message: "操作成功",
                            type: "success",
                        });
                    });
                });
        },
    }
};
</script>

<style scoped>
.custom-radio .el-radio__label {
    display: none;
}

.hidden-label {
    display: inline-block;
    width: 0;
    height: 0;
    overflow: hidden;
}
</style>