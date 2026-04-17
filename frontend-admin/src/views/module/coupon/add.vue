<template>
  <div>
    <el-card class="form-container" shadow="never">
      <aside style="margin-bottom: 20px">添加优惠券</aside>
      <el-form label-width="120px" size="medium">
        <el-form-item label="优惠劵名称">
          <el-input v-model="form.name" maxlength="255"></el-input>
        </el-form-item>
        <el-form-item label="金额">
          <el-input-number v-model="form.reduce_price" :precision="2" :step="1" :min="0" :max="99999999.99"
            style="width: 100%;"></el-input-number>
        </el-form-item>
        <el-form-item label="最低消费">
          <el-input-number v-model="form.min_price" :precision="2" :step="1" :min="0" :max="99999999.99"
            style="width: 100%;"></el-input-number>
        </el-form-item>
        <el-form-item label="发放数量">
          <el-input-number v-model="form.total_num" :precision="0" :step="1" :min="0"
            :max="99999999" style="width: 100%;"></el-input-number>
        </el-form-item>
        <el-form-item label="领取后有效天数">
          <el-input-number v-model="form.expire_day" :precision="0" :step="1" :min="0"
            :max="99999999" style="width: 100%;"></el-input-number>
        </el-form-item>
        <el-form-item style="text-align: center; margin-top: 20px">
          <el-button :disabled="disabled" type="primary" @click="clickSubmit">提交</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script>
import { add } from '@/api/coupon';
export default {
  data() {
    return {
      form: {
        name: '',
        reduce_price: '',
        min_price: '',
        total_num: '',
        expire_day: ''
      },

      disabled: false
    };
  },
  created() { },
  methods: {
    clickSubmit() {
      let that = this;

      if (that.disabled) return;

      if (!that.form.name.length) {
        that.$message.error("请输入名称");
        return;
      }
      if (typeof that.form.reduce_price != 'number') {
        that.$message.error("请输入金额");
        return;
      }
      if (typeof that.form.min_price != 'number') {
        that.$message.error("请输入最低消费");
        return;
      }
      if (typeof that.form.total_num != 'number') {
        that.$message.error("请输入发放数量");
        return;
      }
      if (typeof that.form.expire_day != 'number') {
        that.$message.error("请输入领取后有效天数");
        return;
      }

      that.disabled = true;

      add(this.form).then(response => {
        that.$message({
          message: "添加成功",
          type: "success",
        });
        that.$router.push({ path: '/module/coupon' });
      }).finally(() => {
        that.disabled = false;
      })
    },
  },
};
</script>