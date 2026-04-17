<template>
  <div class="app-container">
    <el-button size="medium" type="primary" @click="dialogVisible = true">添加</el-button>
    <el-table ref="table" v-loading="listLoading" :data="list" :height="tableHeight" style="margin-top: 15px"
      element-loading-text="Loading" border fit highlight-current-row>
      <el-table-column label="ID" width="75" align="center">
        <template slot-scope="scope">
          <span>{{ scope.row.id }}</span>
        </template>
      </el-table-column>
      <el-table-column label="图片" align="center">
        <template slot-scope="scope">
          <el-image style="width: 230px; height: 100px" :src="scope.row.image_url"></el-image>
        </template>
      </el-table-column>
      <el-table-column label="内容" align="center">
        <template slot-scope="scope">
          <router-link :to="{ path: '/banner/articleContent/' + scope.row.id }">
            <el-button type="text" icon="el-icon-edit">设置内容</el-button>
          </router-link>
        </template>
      </el-table-column>
      <el-table-column label="添加时间" align="center">
        <template slot-scope="scope">
          <i class="el-icon-time" />
          <span>{{ scope.row.create_time }}</span>
        </template>
      </el-table-column>
      <el-table-column width="130" label="操作" align="center">
        <template slot-scope="scope">
          <el-button size="mini" type="danger" icon="el-icon-delete" @click="clickDelete(scope.row.id)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog title="添加" width="30%" :visible.sync="dialogVisible" @close="closeDialog">
      <el-form label-position="left" label-width="80px" size="medium">
        <el-form-item label="上传图片">
          <el-upload ref="upload" drag :multiple="false" :auto-upload="true" :show-file-list="false"
            :headers="{ token: upload.token }" :action="upload.url" :on-success="handleUploadSuccess"
            :before-upload="beforeUpload" name="file">
            <img v-if="form.image_url.length" :src="form.image_url" />
            <i v-if="!form.image_url.length" class="el-icon-upload"></i>
            <div v-if="!form.image_url.length" class="el-upload__text">
              将文件拖到此处，或<em>点击上传</em>
            </div>
          </el-upload>
        </el-form-item>
      </el-form>

      <span slot="footer">
        <el-button size="medium" @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" size="medium" @click="clickConfirmAdd">确定</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
import { getToken } from "@/utils/auth";
import { getList, add, del } from "@/api/banner";
export default {
  data() {
    return {
      list: [],
      listLoading: false,
      tableHeight: window.innerHeight - 145,

      dialogVisible: false,
      upload: {
        url: "",
        token: "",
      },

      form: {
        image_url: "",
      },
    };
  },
  created() {
    this.upload.url = "/myapp/admin/file/upload";
    this.upload.token = getToken();

    this.fetchData();
  },
  methods: {
    closeDialog() {
      this.$refs.upload.clearFiles();
    },
    clickConfirmAdd() {
      let that = this;

      if (!that.form.image_url.length) {
        this.$message.error("请上传图片");
        return;
      }

      add(this.form).then((response) => {
        that.form.image_url = '';
        that.dialogVisible = false;

        that.fetchData();
      });
    },
    clickDelete(id) {
      let that = this;
      that
        .$confirm("确认删除吗?", "Prompt", {
          confirmButtonText: "确认",
          cancelButtonText: "取消",
          type: "warning",
        })
        .then(() => {
          del(id).then((response) => {
            const index = that.list.findIndex(item => item.id == id);
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
    fetchData() {
      let that = this;

      that.listLoading = true;
      getList().then((response) => {
        that.list = response.data;
        that.listLoading = false;
      });
    },
    beforeUpload(file) {
      const isJpgPng = file.type === "image/jpeg" || file.type === "image/png";
      const isLt3M = file.size / 1024 / 1024 < 5;
      if (!isJpgPng) {
        this.$message.error("上传图片格式只能是 JPG／PNG 格式!");
      }
      if (!isLt3M) {
        this.$message.error("上传图片大小不能超过 5MB!");
      }
      return isJpgPng && isLt3M;
    },
    handleUploadSuccess(res, file) {
      this.form.image_url = res.data.file_url;

      this.$message({
        message: "上传成功",
        type: "success",
      });
    },
  },
};
</script>

<style scoped>
.el-upload-dragger {
  width: 280px;
  height: 140px;
}

.el-upload-dragger .el-icon-upload {
  /* margin: 42px; */
}
</style>