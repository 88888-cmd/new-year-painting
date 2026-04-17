<template>
  <div>
    <el-card class="form-container" shadow="never">
      <el-steps :active="active" finish-status="success" align-center simple style="margin-bottom: 50px">
        <el-step title="商品信息"></el-step>
        <el-step title="商品规格"></el-step>
        <el-step title="商品详情"></el-step>
        <el-step title="物流设置"></el-step>
      </el-steps>
      <el-form v-show="active == 0" label-width="120px" size="medium">
        <el-form-item label="封面图片">
          <multi-upload v-model="form.image_urls" size="500 * 500"></multi-upload>
        </el-form-item>
        <el-form-item label="名称">
          <el-input v-model="form.name" maxlength="255"></el-input>
        </el-form-item>
        <el-form-item label="分类">
          <el-select v-model="form.category_id" style="width: 100%;">
            <el-option v-for="(item, index) in categoryList" :key="index" :label="item.name"
              :value="item.id"></el-option>
          </el-select>
        </el-form-item>

        <el-form-item style="text-align: center; margin-top: 20px">
          <el-button @click="active++">下一步</el-button>
        </el-form-item>
      </el-form>

      <el-form v-show="active == 1" label-width="120px" size="medium">
        <div>
          <el-table style="width: 100%" :data="form.skus" border>
            <el-table-column label="名称" align="center">
              <template slot-scope="scope">
                <el-input size="small" maxlength="20" v-model="scope.row.sku_name"></el-input>
              </template>
            </el-table-column>
            <el-table-column label="价格" align="center">
              <template slot-scope="scope">
                <el-input-number size="small" v-model="scope.row.price" :precision="2" :step="1" :min="0"
                  :max="99999999.99" style="width: 100%"></el-input-number>
              </template>
            </el-table-column>
            <el-table-column label="划线价" align="center">
              <template slot-scope="scope">
                <el-input-number size="small" v-model="scope.row.line_price" :precision="2" :step="1" :min="0"
                  :max="99999999.99" style="width: 100%"></el-input-number>
              </template>
            </el-table-column>
            <el-table-column width="100" align="center">
              <template slot="header">
                <el-button size="mini" type="primary" @click="clickAddSku">添加</el-button>
              </template>
              <template slot-scope="scope">
                <el-button size="mini" type="danger" @click="clickRemoveSku(scope.$index)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>

        <el-form-item style="text-align: center; margin-top: 20px">
          <el-button @click="active--">上一步</el-button>
          <el-button @click="active++">下一步</el-button>
        </el-form-item>
      </el-form>

      <el-form v-show="active == 2" label-width="120px" size="medium">
        <el-form-item label="图片">
          <el-upload :action="upload.url" :headers="{ token: upload.token }" :multiple="false" :show-file-list="false"
            :before-upload="beforeUploadDetailImage" :on-success="uploadDetailImageSuccess" name="file">
            <el-button type="primary">点击上传</el-button>
          </el-upload>
          <el-image v-if="form.detail_url.length" style="width: 400px; height: auto; margin-top: 20px;"
            :src="form.detail_url" fit="fill"></el-image>
        </el-form-item>

        <el-form-item style="text-align: center; margin-top: 30px">
          <el-button @click="active--">上一步</el-button>
          <el-button @click="active++">下一步</el-button>
        </el-form-item>
      </el-form>

      <el-form v-show="active == 3" label-width="120px" size="medium">

        <el-form-item label="运费类型">
          <el-radio-group v-model="form.freight_type">
            <el-radio :label="1">包邮</el-radio>
            <el-radio :label="2">固定邮费</el-radio>
            <el-radio :label="3">运费模板</el-radio>
          </el-radio-group>
        </el-form-item>

        <el-form-item v-if="form.freight_type == 2" label="运费金额">
          <el-input-number size="small" v-model="form.freight_price" :precision="2" :step="1" :min="0"
            :max="99999999.99"></el-input-number>
        </el-form-item>

        <el-form-item v-if="form.freight_type == 3" label="模板">
          <el-select v-model="form.freight_temp_id">
            <el-option v-for="(item, index) in freightTempList" :key="index" :label="item.name"
              :value="item.id"></el-option>
          </el-select>
        </el-form-item>


        <el-form-item style="text-align: center; margin-top: 30px">
          <el-button @click="active--">上一步</el-button>
          <el-button :disabled="disabled" type="primary" @click="clickSubmit">提交</el-button>
        </el-form-item>

      </el-form>
    </el-card>
  </div>
</template>

<script>
import { getToken } from "@/utils/auth";
import { getList as getFreightTempList } from '@/api/freightTemp';
import { getList as getCategoryList } from "@/api/goodsCategory";
import { detail, edit } from "@/api/goods";
import MultiUpload from "@/components/Upload/multiUpload";
export default {
  components: {
    MultiUpload,
  },
  data() {
    return {
      active: 0,

      upload: {
        url: "",
        token: "",
      },

      form: {
        image_urls: [],
        name: "",
        category_id: '',
        detail_url: '',
        freight_type: 1,
        freight_price: '',
        freight_temp_id: '',
        skus: []
      },

      categoryList: [],
      freightTempList: [],

      disabled: false,
    };
  },
  created() {
    this.upload.url = "/myapp/admin/file/upload";
    this.upload.token = getToken();

    this.fetchData();
  },
  methods: {
    clickAddSku() {
      this.form.skus.push({
        sku_name: '',
        price: '',
        line_price: ''
      })
    },
    clickRemoveSku(index) {
      this.form.skus.splice(index, 1);
    },
    async fetchData() {
      this.disabled = true;
      try {
        const categoryResult = await getCategoryList();
        this.categoryList = categoryResult.data;

        const freightTempResult = await getFreightTempList();
        this.freightTempList = freightTempResult.data;

        const detailResult = await detail(this.$route.params.id);
        for (let key in detailResult.data) {
          if (this.form.hasOwnProperty(key)) {
            this.form[key] = detailResult.data[key];
          }
        }

        this.disabled = false;
      } catch (e) { }
    },
    clickSubmit() {
      if (this.disabled) return;

      if (!this.form.image_urls.length) {
        this.$message.error("请上传封面图片");
        return;
      }
      if (!this.form.name.length) {
        this.$message.error("请输入名称");
        return;
      }
      if (!this.form.category_id) {
        this.$message.error("请选择分类");
        return;
      }

      const skus = this.form.skus;

      if (!skus.length) {
        this.$message.error("请添加规格");
        return;
      }
      for (const item of skus) {
        console.log(item)
        if (!item.sku_name.length) {
          this.$message.error("请输入规格名称");
          return;
        }
        if (typeof item.price != "number") {
          this.$message.error("请输入规格价格");
          return;
        }
      }
      if (this.form.freight_type == 3 && !this.form.freight_temp_id) {
        this.$message.error("请选择规格模板");
        return;
      }

      this.disabled = true;

      edit({ goods_id: this.$route.params.id, ...this.form })
        .then((response) => {
          this.$message({
            message: "编辑成功",
            type: "success",
          });
          this.$router.push({ path: "/goods/list" });
        })
        .finally(() => {
          this.disabled = false;
        });
    },
    beforeUploadDetailImage(file) {
      const isJpgPng = file.type === "image/jpeg" || file.type === "image/png";
      const isLt5M = file.size / 1024 / 1024 < 5;
      if (!isJpgPng) {
        this.$message.error("上传图片只能是 JPG/PNG 格式!");
      }
      if (!isLt5M) {
        this.$message.error("上传图片大小不能超过 5MB!");
      }
      return isJpgPng && isLt5M;
    },
    uploadDetailImageSuccess(res, file) {
      if (res.code == 1) {
        this.$message.error(res.msg);
        return;
      }
      this.form.detail_url = res.data.file_url;
      this.$message({
        message: "上传成功",
        type: "success",
      });
    },
  },
};
</script>
