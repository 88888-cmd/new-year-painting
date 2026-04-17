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
            <el-table-column label="分类名称" align="center">
                <template slot-scope="scope">
                    <span>{{ scope.row.name }}</span>
                </template>
            </el-table-column>
            <el-table-column label="添加时间" align="center">
                <template slot-scope="scope">
                    <i class="el-icon-time" />
                    <span>{{ scope.row.create_time }}</span>
                </template>
            </el-table-column>
            <el-table-column width="230" label="操作" align="center">
                <template slot-scope="scope">
                    <el-button size="mini" type="warning" icon="el-icon-edit" @click="openEditDialog(scope.row.id)"
                        style="margin-left: 10px">编辑</el-button>
                    <el-button size="mini" type="danger" icon="el-icon-delete"
                        @click="clickDelete(scope.row.id)">删除</el-button>
                </template>
            </el-table-column>
        </el-table>

        <el-dialog title="表单" width="30%" :visible.sync="dialogVisible">
            <el-form label-position="left" label-width="80px" size="medium">
                <el-form-item label="名称">
                    <el-input v-model="form.name" placeholder="请输入名称" maxlength="50"></el-input>
                </el-form-item>
            </el-form>

            <span slot="footer">
                <el-button size="medium" @click="dialogVisible = false">取消</el-button>
                <el-button type="primary" size="medium" @click="clickSubmit">确定</el-button>
            </span>
        </el-dialog>
    </div>
</template>

<script>
import { getList, add, edit, del } from '@/api/goodsCategory';
export default {
    data() {
        return {
            list: [],
            listLoading: false,
            tableHeight: window.innerHeight - 145,

            dialogVisible: false,
            form: {
                category_id: 0,
                name: ''
            }
        };
    },
    created() {
        this.fetchData();
    },
    methods: {
        openAddDialog() {
            Object.assign(this.$data.form, this.$options.data().form);

            this.dialogVisible = true;
        },
        openEditDialog(id) {
            const category = this.list.find(item => item.id == id);

            this.form.category_id = id;
            this.form.name = category.name;

            this.dialogVisible = true;
        },
        clickSubmit() {
            let that = this;

            if (!that.form.name.length) {
                that.$message.error("请输入分类名称");
                return;
            }

            that.dialogVisible = false;

            if (that.form.category_id != 0) {
                edit({ category_id: that.form.category_id, name: that.form.name }).then(response => {
                    that.$message({
                        message: "修改成功",
                        type: "success",
                    });
                    that.fetchData();
                })
            } else {
                add({ name: that.form.name }).then(response => {
                    that.$message({
                        message: "添加成功",
                        type: "success",
                    });
                    that.fetchData();
                })
            }
        },
        fetchData() {
            let that = this;

            that.listLoading = true;

            getList().then((response) => {
                that.list = response.data;
                that.listLoading = false;
            });
        },
        clickDelete(id, parent_id) {
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
    },
};
</script>