<template>
  <div class="app-container">
    <router-link :to="{ path: '/module/addPointsTask' }">
      <el-button size="medium" type="primary">添加</el-button>
    </router-link>
    <el-table ref="multipleTable" v-loading="listLoading" :data="list" :height="tableHeight"
      element-loading-text="Loading" border fit highlight-current-row style="margin-top: 15px">
      <el-table-column label="ID" width="75" align="center">
        <template slot-scope="scope">
          <span>{{ scope.row.id }}</span>
        </template>
      </el-table-column>
      <el-table-column label="任务类型" align="center">
        <template slot-scope="scope">
          <span>{{ scope.row.task_type_display }}</span>
        </template>
      </el-table-column>
      <el-table-column label="指定年画" align="center">
        <template slot-scope="scope">
          <span v-if="scope.row.painting_id == 0">不指定</span>
          <span v-else>ID：{{ scope.row.painting_id }}</span>
        </template>
      </el-table-column>
      <el-table-column label="每日次数限制" align="center">
        <template slot-scope="scope">
          <span>{{ scope.row.daily_limit }}</span>
        </template>
      </el-table-column>
      <el-table-column label="单次积分奖励" align="center">
        <template slot-scope="scope">
          <span>{{ scope.row.point_reward }}</span>
        </template>
      </el-table-column>
      <el-table-column label="添加时间" align="center">
        <template slot-scope="scope">
          <i class="el-icon-time" />
          <span>{{ scope.row.create_time }}</span>
        </template>
      </el-table-column>
      <el-table-column width="230" label="操作" align="center">
        <template slot-scope="scope">
          <router-link :to="{ path: '/module/editPointsTask/' + scope.row.id }">
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
import { getList, del } from '@/api/pointsTask';
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