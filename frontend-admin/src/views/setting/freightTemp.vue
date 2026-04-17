<template>
  <div class="app-container">
    <router-link :to="{ path: '/setting/addFreightTemp' }">
      <el-button size="medium" type="primary">添加运费模板</el-button>
    </router-link>
    <el-table ref="multipleTable" v-loading="listLoading" :data="list" :height="tableHeight"
      element-loading-text="Loading" border fit highlight-current-row style="margin-top: 15px">
      <el-table-column label="ID" width="75" align="center">
        <template slot-scope="scope">
          <span>{{ scope.row.id }}</span>
        </template>
      </el-table-column>
      <el-table-column label="规则名称" align="center">
        <template slot-scope="scope">
          <span>{{ scope.row.name }}</span>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center">
        <template slot-scope="scope">
          <i class="el-icon-time" />
          <span>{{ scope.row.create_time }}</span>
        </template>
      </el-table-column>
      <el-table-column width="230" label="操作" align="center">
        <template slot-scope="scope">
          <router-link :to="{ path: '/setting/editFreightTemp/' + scope.row.id }">
            <el-button size="mini" type="warning" icon="el-icon-edit">编辑</el-button>
          </router-link>
          <el-button size="mini" type="danger" icon="el-icon-delete" style="margin-left: 10px"
            @click="clickDelete(scope.row.id)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script>
import { getList, del } from '@/api/freightTemp';
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