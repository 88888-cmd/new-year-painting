<template>
  <div>
    <el-card class="form-container" shadow="never">
      <aside style="margin-bottom: 20px">添加积分任务</aside>
      <el-form label-width="120px" size="medium">
        <el-form-item label="任务类型">
          <el-select v-model="form.task_type" style="width: 100%">
            <el-option v-for="(item, index) in [
              { id: 1, name: '浏览年画' },
              { id: 2, name: '收藏年画' },
              { id: 3, name: '评论年画' }
            ]" :key="index" :label="item.name" :value="item.id"></el-option>
          </el-select>
        </el-form-item>

        <el-form-item label="指定年画">
          <el-radio-group v-model="isPaintingLimited">
            <el-radio :label="true">选择年画</el-radio>
            <el-radio :label="false">不限（所有年画）</el-radio>
          </el-radio-group>

          <el-input v-model="selectedPaintingName" readonly :placeholder="isPaintingLimited ? '请选择年画' : '已选择不限（所有年画）'"
            style="width: 80%; margin-top: 10px" :disabled="!isPaintingLimited">
            <template #append>
              <el-button icon="el-icon-search" @click="isPaintingLimited && (dialogVisible = true)"
                :disabled="!isPaintingLimited">选择</el-button>
            </template>
          </el-input>
        </el-form-item>

        <el-form-item label="每日次数限制">
          <el-input-number v-model="form.daily_limit" :precision="0" :step="1" :min="0" :max="100"
            style="width: 100%;"></el-input-number>
        </el-form-item>
        <el-form-item label="单次积分奖励">
          <el-input-number v-model="form.point_reward" :precision="0" :step="1" :min="0" :max="99999999"
            style="width: 100%;"></el-input-number>
        </el-form-item>
        <el-form-item style="text-align: center; margin-top: 20px">
          <el-button :disabled="disabled" type="primary" @click="clickSubmit">提交</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-dialog title="选择年画" :visible.sync="dialogVisible" width="70%" :before-close="handleDialogClose">
      <el-table ref="paintingTable" :data="paintings" border fit highlight-current-row @row-click="handleRowClick"
        :row-class-name="tableRowClassName">
        <el-table-column label="选择" width="60" align="center">
          <template slot-scope="scope">
            <el-radio :label="scope.row.id" v-model="selectedPaintingId" class="custom-radio">
              <span class="hidden-label"></span>
            </el-radio>
          </template>
        </el-table-column>
        <el-table-column label="ID" width="75" align="center">
          <template slot-scope="scope">{{ scope.row.id }}</template>
        </el-table-column>
        <el-table-column label="图片" align="center">
          <template slot-scope="scope">
            <el-image style="width: 70px; height: 70px; vertical-align: middle" :src="scope.row.image_url"
              fit="cover"></el-image>
          </template>
        </el-table-column>
        <el-table-column label="名称" align="center">
          <template slot-scope="scope">{{ scope.row.name }}</template>
        </el-table-column>
        <el-table-column label="添加时间" align="center">
          <template slot-scope="scope">
            <i class="el-icon-time"></i>
            <span>{{ scope.row.create_time }}</span>
          </template>
        </el-table-column>
      </el-table>
      <div slot="footer" class="dialog-footer">
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmPaintingSelection">确定</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { add } from '@/api/pointsTask';
import { getList } from '@/api/painting';

export default {
  data() {
    return {
      form: {
        task_type: 1,
        painting_id: 0,
        daily_limit: 1,
        point_reward: 0
      },
      paintings: [],
      dialogVisible: false,
      selectedPaintingName: '',
      selectedPaintingId: 0,
      isPaintingLimited: false,
      disabled: false
    };
  },
  created() {
    this.fetchPaintings();
  },
  watch: {
    isPaintingLimited(val) {
      if (!val) {
        this.selectedPaintingId = 0;
        this.selectedPaintingName = '';
        this.form.painting_id = 0;
      }
    }
  },
  methods: {
    fetchPaintings() {
      getList().then(response => {
        this.paintings = response.data;
      });
    },
    handleRowClick(row) {
      this.selectedPaintingId = row.id;
      this.selectedPaintingName = row.name;
    },
    tableRowClassName({ row }) {
      return row.id === this.selectedPaintingId ? 'el-table__row--active' : '';
    },
    handleDialogClose(done) {
      if (this.isPaintingLimited && this.selectedPaintingId === 0) {
        this.$confirm('确定不选择年画吗？', '提示', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        }).then(() => {
          done();
        }).catch(() => {
        });
      } else {
        done();
      }
    },
    confirmPaintingSelection() {
      if (this.isPaintingLimited && this.selectedPaintingId === 0) {
        this.$message.warning('请选择一幅年画');
        return;
      }

      this.form.painting_id = this.selectedPaintingId;
      this.dialogVisible = false;
    },
    clickSubmit() {
      let that = this;

      if (that.disabled) return;

      if (typeof that.form.daily_limit !== 'number') {
        that.$message.error("请输入每日次数限制");
        return;
      }
      if (typeof that.form.point_reward !== 'number') {
        that.$message.error("请输入单次积分奖励");
        return;
      }

      that.disabled = true;

      add(this.form).then(response => {
        that.$message({
          message: "添加成功",
          type: "success",
        });
        that.$router.push({ path: '/module/pointsTask' });
      }).finally(() => {
        that.disabled = false;
      })
    }
  }
};
</script>

<style scoped>
.custom-radio .el-radio__label {
  display: none;
}

.hidden-label {
  display: inline-block;
  width: 0;
  height: 0;
  overflow: hidden;
}
</style>