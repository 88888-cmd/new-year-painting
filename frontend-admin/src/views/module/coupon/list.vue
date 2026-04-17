<template>
  <div class="app-container">
    <router-link :to="{ path: '/module/couponLog' }">
      <el-button type="text" size="medium" icon="el-icon-view">领取记录</el-button>
    </router-link>
    <router-link :to="{ path: '/module/addCoupon' }" style="margin-left: 50px;">
      <el-button size="medium" type="primary">添加</el-button>
    </router-link>
    <el-table ref="multipleTable" v-loading="listLoading" :data="list" :height="tableHeight"
      element-loading-text="Loading" border fit highlight-current-row style="margin-top: 15px">
      <el-table-column label="ID" width="75" align="center">
        <template slot-scope="scope">
          <span>{{ scope.row.id }}</span>
        </template>
      </el-table-column>
      <el-table-column label="优惠券名称" align="center">
        <template slot-scope="scope">
          <span>{{ scope.row.name }}</span>
        </template>
      </el-table-column>
      <el-table-column label="金额" align="center">
        <template slot-scope="scope">
          <span>{{ scope.row.reduce_price }}</span>
        </template>
      </el-table-column>
      <el-table-column label="最低消费" align="center">
        <template slot-scope="scope">
          <span>{{ scope.row.min_price }}</span>
        </template>
      </el-table-column>
      <el-table-column label="发放数量" align="center">
        <template slot-scope="scope">
          <span v-if="scope.row.total_num == 0">不限制</span>
          <span v-else>{{ scope.row.total_num }}</span>
        </template>
      </el-table-column>
      <el-table-column label="领取后有效天数" align="center">
        <template slot-scope="scope">
          <span v-if="scope.row.expire_day == 0">不限制</span>
          <span v-else>{{ scope.row.expire_day }}天</span>
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
          <el-button size="mini" type="danger" icon="el-icon-delete" style="margin-left: 10px"
            @click="clickDelete(scope.row.id)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script>
import { getList, del } from '@/api/coupon';
export default {
  data() {
    return {
      list: [],
      listLoading: false,
      tableHeight: window.innerHeight - 145,
    };
  },
  created() {
    this.fetchData();
  },
  methods: {
    fetchData() {
      let that = this;

      that.listLoading = true;

      getList().then((response) => {
        that.list = response.data;
        that.listLoading = false;
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
  },
};
</script>