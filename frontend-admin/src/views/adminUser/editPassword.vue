<template>
    <div>
        <el-card class="form-container" shadow="never">
            <aside style="margin-bottom: 20px">修改密码</aside>
            <el-form label-width="120px" size="medium">
                <el-form-item label="旧密码">
                    <el-input v-model="form.old_password" maxlength="100" placeholder="请输入旧密码" show-password></el-input>
                </el-form-item>
                <el-form-item label="新密码">
                    <el-input v-model="form.new_password" maxlength="100" placeholder="请输入新密码" show-password></el-input>
                </el-form-item>
                <el-form-item label="重复新密码">
                    <el-input v-model="form.re_new_password" maxlength="100" placeholder="请再次输入新密码" show-password></el-input>
                </el-form-item>
                <el-form-item style="text-align: center; margin-top: 20px">
                    <el-button type="primary" size="medium" @click="clickSubmit">提交</el-button>
                </el-form-item>
            </el-form>
        </el-card>
    </div>
</template>

<script>
import { editPassword } from "@/api/admin";
export default {
    data() {
        return {
            form: {
                old_password: '',
                new_password: '',
                re_new_password: ''
            }
        };
    },
    created() { },
    methods: {
        clickSubmit() {
            let that = this;

            if (!that.form.old_password.length) {
                this.$message.error("请输入旧密码");
                return;
            }
            if (!that.form.new_password.length) {
                this.$message.error("请输入新密码");
                return;
            }
            if (that.form.re_new_password != that.form.new_password) {
                this.$message.error("两次输入密码不一致");
                return;
            }

            editPassword(that.form.old_password, that.form.new_password).then((response) => {
                that.$message({
                    message: "修改成功",
                    type: "success",
                });
            });
        }
    },
};
</script>