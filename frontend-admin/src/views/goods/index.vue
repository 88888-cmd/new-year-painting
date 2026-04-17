<template>
  <div class="app-container">
    <el-input
      v-model="search"
      placeholder="搜索商品名称"
      style="width: 200px"
      size="medium"
    ></el-input>

    <router-link :to="{ path: '/goods/add' }" style="margin-left: 30px">
      <el-button size="medium" type="primary">添加</el-button>
    </router-link>

    <el-table
      ref="multipleTable"
      v-loading="listLoading"
      :data="goodsDatas"
      :height="tableHeight"
      element-loading-text="Loading"
      border
      fit
      highlight-current-row
      style="margin-top: 15px"
    >
      <el-table-column label="ID" width="75" align="center">
        <template slot-scope="scope">
          <span>{{ scope.row.id }}</span>
        </template>
      </el-table-column>
      <el-table-column label="图片" align="center">
        <template slot-scope="scope">
          <el-image
            style="width: 70px; height: 70px; vertical-align: middle"
            :src="scope.row.image_urls[0]"
            fit="cover"
          ></el-image>
        </template>
      </el-table-column>
      <el-table-column label="名称" align="center">
        <template slot-scope="scope">
          <span>{{ scope.row.name }}</span>
        </template>
      </el-table-column>
      <el-table-column width="200" label="添加时间" align="center">
        <template slot-scope="scope">
          <i class="el-icon-time" />
          <span>{{ scope.row.create_time }}</span>
        </template>
      </el-table-column>
      <el-table-column width="230" label="操作" align="center">
        <template slot-scope="scope">
          <router-link :to="{ path: '/goods/edit/' + scope.row.id }">
            <el-button size="mini" type="warning" icon="el-icon-edit"
              >编辑</el-button
            >
          </router-link>
          <el-button
            size="mini"
            type="danger"
            icon="el-icon-delete"
            style="margin-left: 10px"
            @click="clickDelete(scope.row.id)"
            >删除</el-button
          >
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script>
import { getList, del } from "@/api/goods";
export default {
  data() {
    return {
      search: "",
      list: [],
      listLoading: false,
      tableHeight: window.innerHeight - 145,
    };
  },
  computed: {
    goodsDatas() {
      return this.list.filter((data) => {
        return data.name.toLowerCase().indexOf(this.search) > -1;
      });
    },
  },
  created() {
    this.fetchData();
  },
  methods: {
    fetchData() {
      this.listLoading = true;
      getList().then((response) => {
        this.list = response.data;
        this.listLoading = false;
      });
    },
    clickDelete(id) {
      this.$confirm("确认删除吗?", "Prompt", {
        confirmButtonText: "确认",
        cancelButtonText: "取消",
        type: "warning",
      }).then(() => {
        del(id).then((response) => {
          const index = this.list.findIndex((item) => item.id == id);
          if (index > -1) {
            this.list.splice(index, 1);
          }

          this.$message({
            message: "操作成功",
            type: "success",
          });
        });
      });
    },
  },
};
</script>