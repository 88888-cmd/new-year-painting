<template>
  <div>
    <div class="image-list">
      <!-- <div class="item">
        <el-image class="image" :src="imgUrl" fit="cover"></el-image>

        <div class="close" @click="clickDeleteImage(index)">
          <i class="el-icon-delete"></i>
        </div>
      </div> -->

      <el-upload class="item" :style="[
        {
          width: `${width}px`,
          height: `${height}px`,
        },
      ]" :action="upload.url" :headers="{ token: upload.token }" :multiple="false" :show-file-list="false"
        :before-upload="beforeUploadImage" :on-success="uploadImageSuccess" name="file">
        <div v-if="!value.length" class="plus" :style="[
          {
            width: `${width}px`,
            height: `${height}px`,
          },
        ]">
          <i class="el-icon-plus"></i>
        </div>

        <img v-else class="image" :src="value" :style="[
          {
            width: `${width}px`,
            height: `${height}px`,
          },
        ]" />
      </el-upload>
    </div>
    <div class="tip">图片尺寸：{{ size }}</div>
  </div>
</template>

<script>
import { getToken } from "@/utils/auth";
export default {
  name: "singleUpload",
  props: {
    value: String,

    width: {
      type: [String, Number],
      default: 100,
    },
    height: {
      type: [String, Number],
      default: 100,
    },
    size: {
      type: String,
      default: '100 * 100',
    },
  },
  data() {
    return {
      upload: {
        url: "",
        token: "",
      },

      // imgUrl: []
    };
  },
  // watch: {
  //   value: {
  //     deep: true,
  //     handler(val) {
  //       if (!this.imgUrl.length) {
  //         this.imgUrl = val;
  //       }
  //     }
  //   },
  // },
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
      // this.imgUrl = res.data.path;
      this.$emit("input", res.data.file_url);
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
}

.image-list .item {
  position: relative;
}

.image-list .item .image {
  display: block;
  object-fit: cover;
}

.image-list .item .plus {
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