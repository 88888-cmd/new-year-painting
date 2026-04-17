<template>
    <div>
        <el-card class="form-container" shadow="never">
            <aside style="margin-bottom: 20px">添加年画</aside>
            <el-form label-width="120px" size="medium">
                <el-form-item label="年画图片">
                    <single-upload v-model="form.image_url" size="不限"></single-upload>
                </el-form-item>
                <el-form-item label="背景音乐">
                    <el-upload :action="upload.url" :headers="{ token: upload.token }" :multiple="false"
                        :show-file-list="false" :before-upload="beforeUploadMp3" :on-success="uploadMp3Success"
                        name="file">
                        <el-button type="primary" size="medium">点击上传</el-button>
                    </el-upload>
                </el-form-item>
                <el-form-item label="名称">
                    <el-input v-model="form.name" maxlength="255"></el-input>
                </el-form-item>
                <el-form-item label="风格">
                    <el-select v-model="form.style_id" style="width: 100%">
                        <el-option v-for="(item, index) in styleList" :key="index" :label="item.name"
                            :value="item.id"></el-option>
                    </el-select>
                </el-form-item>
                <el-form-item label="题材">
                    <el-select v-model="form.theme_id" style="width: 100%">
                        <el-option v-for="(item, index) in themeList" :key="index" :label="item.name"
                            :value="item.id"></el-option>
                    </el-select>
                </el-form-item>
                <el-form-item label="年代">
                    <el-select v-model="form.dynasty_id" style="width: 100%">
                        <el-option v-for="(item, index) in dynastyList" :key="index" :label="item.name"
                            :value="item.id"></el-option>
                    </el-select>
                </el-form-item>
                <el-form-item label="作者">
                    <el-select v-model="form.author_id" style="width: 100%">
                        <el-option v-for="(item, index) in authorList" :key="index" :label="item.name"
                            :value="item.id"></el-option>
                    </el-select>
                </el-form-item>
                <el-form-item label="内容">
                    <el-input v-model="form.content" type="textarea" maxlength="500"></el-input>
                </el-form-item>


                <el-form-item style="text-align: center; margin-top: 20px">
                    <el-button :disabled="disabled" type="primary" @click="clickSubmit">提交</el-button>
                </el-form-item>
            </el-form>
        </el-card>
    </div>
</template>

<script>
import { add, getFilterOptions } from "@/api/painting";
import SingleUpload from "@/components/Upload/singleUpload";
import { getToken } from "@/utils/auth";
export default {
    components: {
        SingleUpload,
    },
    data() {
        return {
            upload: {
                url: "",
                token: "",
            },

            form: {
                image_url: "",
                bg_mp3_url: '',
                name: '',
                style_id: '',
                theme_id: '',
                dynasty_id: '',
                author_id: '',
                content: ''
            },

            styleList: [],
            themeList: [],
            dynastyList: [],
            authorList: [],

            disabled: false,
        };
    },
    created() {
        this.upload.url = "/myapp/admin/file/upload";
        this.upload.token = getToken();

        this.getFilterOptions();
    },
    methods: {
        getFilterOptions() {
            this.disabled = true;
            getFilterOptions().then((response) => {
                this.styleList = response.data.styles;
                this.themeList = response.data.themes;
                this.dynastyList = response.data.dynasties;
                this.authorList = response.data.authors;
                this.disabled = false;
            });
        },
        clickSubmit() {
            if (this.disabled) return;

            if (!this.form.image_url.length) {
                this.$message.error("请上传图片");
                return;
            }
            if (!this.form.name.length) {
                this.$message.error("请输入名称");
                return;
            }
            if (!this.form.content.length) {
                this.$message.error("请输入内容");
                return;
            }

            this.disabled = true;

            add({ ...this.form })
                .then((response) => {
                    this.$message({
                        message: "添加成功",
                        type: "success",
                    });
                    this.$router.push({ path: "/painting/list" });
                })
                .finally(() => {
                    this.disabled = false;
                });
        },
        beforeUploadMp3(file) {
            const isJpgPng = file.type === "audio/mpeg";
            const isLt5M = file.size / 1024 / 1024 < 5;
            const fileExtension = file.name.split('.').pop().toLowerCase();
            const isMp3Extension = fileExtension === 'mp3';
            if (!isJpgPng) {
                this.$message.error("上传文件只能是 MP3 格式!");
            }
            if (!isLt5M) {
                this.$message.error("上传文件大小不能超过 5MB!");
            }
            if (!isMp3Extension) {
                this.$message.error("上传文件必须是 .mp3 后缀!");
            }
            return isJpgPng && isLt5M;
        },
        uploadMp3Success(res) {
            if (res.code == 1) {
                this.$message.error(res.msg);
                return;
            }
            this.form.bg_mp3_url = res.data.file_url;
            this.$message({
                message: "上传成功",
                type: "success",
            });
        },
    },
};
</script>
