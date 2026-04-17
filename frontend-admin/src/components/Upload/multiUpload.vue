<template>
  <div>
    <div class="image-list">
      <div class="item" v-for="(item, index) in imgList" :key="index">
        <el-image class="image" :src="item" fit="cover"></el-image>

        <div class="close" @click="clickDeleteImage(index)">
          <i class="el-icon-delete"></i>
        </div>
      </div>

      <el-upload v-if="imgList.length < limit" class="item" :action="upload.url" :headers="{ token: upload.token }"
        :multiple="false" :show-file-list="false" :before-upload="beforeUploadImage" :on-success="uploadImageSuccess"
        name="file">
        <div class="plus">
          <i class="el-icon-plus"></i>
        </div>
      </el-upload>
    </div>
    <div class="tip">图片尺寸：{{ size }}</div>
  </div>
</template>

<script>
import { getToken } from "@/utils/auth";
export default {
  name: "multiUpload",
  props: {
    value: Array,

    limit: {
      type: Number,
      default: 10,
    },

    size: {
      type: String,
      default: "100 * 100",
    },
  },
  data() {
    return {
      upload: {
        url: "",
        token: "",
      },

      imgList: [],
    };
  },
  watch: {
    value: {
      deep: true,
      handler(val) {
        if (!this.imgList.length) {
          this.imgList = val;
        }
      },
    },
  },
  created() {
    this.upload.url = "/myapp/admin/file/upload";
    this.upload.token = getToken();
  },
  methods: {
    beforeUploadImage(file) {
      const isJpgPng = file.type === "image/jpeg" || file.type === "image/png";
      const isLt5M = file.size / 1024 / 1024 < 5;
      if (!isJpgPng) {
        this.$message.error("上传图片只能是 JPG/PNG 格式!");
        return false;
      }
      if (!isLt5M) {
        this.$message.error("上传图片大小不能超过 5MB!");
        return false;
      }
      return isJpgPng && isLt5M;
    },
    uploadImageSuccess(res, file) {
      if (res.code != 0) {
        this.$message.error(res.message);
        return;
      }
      this.imgList.push(res.data.file_url);
      this.$emit("input", this.imgList);
    },
    clickDeleteImage(index) {
      this.imgList.splice(index, 1);
      this.$emit("input", this.imgList);
    },
  },
};
</script>

<style scoped>
.tip {
  font-size: 12px;
  color: #606266;
}

.image-list {
  display: flex;
  flex-wrap: wrap;
  justify-content: flex-start;
  align-items: flex-start;
  width: 100%;
  row-gap: 10px;
  column-gap: 10px;
}

.image-list .item {
  position: relative;
  width: 100px;
  height: 100px;
}

.image-list .item .image {
  display: block;
  width: 100px;
  height: 100px;
}

.image-list .item .plus {
  width: 100px;
  height: 100px;
  border: 1px dashed #c0ccda;
  background-color: #fbfdff;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
}

.image-list .item .plus .el-icon-plus {
  font-size: 25px;
  color: #8c939d;
}

.image-list .item .close {
  width: 25px;
  height: 25px;
  position: absolute;
  top: 0;
  right: 0;
  background-color: rgba(0, 0, 0, 0.5);
  color: white;
  font-size: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
}
</style>