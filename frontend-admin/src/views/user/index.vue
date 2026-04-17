<template>
    <div class="app-container">
        <el-table ref="multipleTable" v-loading="listLoading" :data="list" :height="tableHeight"
            element-loading-text="Loading" border fit highlight-current-row>
            <el-table-column label="ID" width="75" align="center">
                <template slot-scope="scope">
                    <span>{{ scope.row.id }}</span>
                </template>
            </el-table-column>
            <el-table-column label="账号" width="200" align="center">
                <template slot-scope="scope">
                    <span v-if="scope.row.phone.length > 0">【手机号】{{ scope.row.phone }}</span>
                    <span v-else>【邮箱】{{ scope.row.email }}</span>
                </template>
            </el-table-column>
            <el-table-column label="头像" width="95" align="center">
                <template slot-scope="scope">
                    <el-avatar v-if="scope.row.avatar_url.length" shape="circle" :size="50"
                        :src="scope.row.avatar_url" />
                    <el-avatar v-else shape="circle" :size="50" icon="el-icon-user-solid" />
                </template>
            </el-table-column>
            <el-table-column label="昵称" align="center">
                <template slot-scope="scope">
                    <span>{{ scope.row.nickname }}</span>
                </template>
            </el-table-column>
            <el-table-column label="性别" width="100" align="center">
                <template slot-scope="scope">
                    <span>{{ scope.row.gender == 0 ? '男' : '女' }}</span>
                </template>
            </el-table-column>
            <el-table-column label="出生日期" width="105" align="center">
                <template slot-scope="scope">
                    <span>{{ scope.row.birthday || '未填写' }}</span>
                </template>
            </el-table-column>
            <el-table-column label="职业" align="center">
                <template slot-scope="scope">
                    <span>{{ scope.row.profession || '未填写' }}</span>
                </template>
            </el-table-column>
            <el-table-column label="普通积分" width="150" align="center">
                <template slot-scope="scope">
                    <span>{{ scope.row.normal_points }}</span>
                </template>
            </el-table-column>
            <el-table-column label="文化积分" width="150" align="center">
                <template slot-scope="scope">
                    <span>{{ scope.row.cultural_points }}</span>
                </template>
            </el-table-column>
            <el-table-column label="注册时间" align="center">
                <template slot-scope="scope">
                    <i class="el-icon-time"></i>
                    <span>{{ scope.row.create_time }}</span>
                </template>
            </el-table-column>
        </el-table>
    </div>
</template>

<script>
import { getList } from '@/api/user';
export default {
    data() {
        return {
            list: [],
            listLoading: false,
            tableHeight: window.innerHeight - 95
        };
    },
    created() {
        this.fetchData();
    },
    methods: {
        fetchData() {
            getList().then((response) => {
                this.list = response.data;
                this.listLoading = false;
            });
        }
    },
};
</script>