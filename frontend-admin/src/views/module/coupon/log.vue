<template>
  <div class="app-container">
    <el-table ref="multipleTable" v-loading="listLoading" :data="list" :height="tableHeight"
      element-loading-text="Loading" border fit highlight-current-row>
      <el-table-column label="用户ID" align="center">
        <template slot-scope="scope">
          <span>{{ scope.row.user_id }}</span>
        </template>
      </el-table-column>
      <el-table-column label="优惠劵名称" width="150" align="center">
        <template slot-scope="scope">
          <span>{{ scope.row.coupon_name }}</span>
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
      <el-table-column label="使用状态" align="center">
        <template slot-scope="scope">
          <span v-if="scope.row.is_use == 0">未使用</span>
          <span v-else>已于{{ scope.row.use_time }}使用</span>
        </template>
      </el-table-column>
      <el-table-column label="领取时间" align="center">
        <template slot-scope="scope">
          <i class="el-icon-time" />
          <span>{{ scope.row.start_time }}</span>
        </template>
      </el-table-column>
      <el-table-column label="有效期至" align="center">
        <template slot-scope="scope">
          <span v-if="scope.row.expire_day == 0">无限</span>
          <span v-else>{{ scope.row.end_time }}</span>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script>
import { getLogList } from '@/api/coupon';
export default {
  data() {
    return {
      list: [],
      listLoading: false,
      tableHeight: window.innerHeight - 95,
    };
  },
  created() {
    this.fetchData();
  },
  methods: {
    fetchData() {
      let that = this;

      that.listLoading = true;

      getLogList().then((response) => {
        that.list = response.data;
        that.listLoading = false;
      });
    }
  },
};
</script>