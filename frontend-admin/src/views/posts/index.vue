<template>
    <div class="app-container">
        <el-table ref="multipleTable" v-loading="listLoading" :data="list" :height="tableHeight"
            element-loading-text="Loading" border fit highlight-current-row>
            <el-table-column label="ID" width="75" align="center">
                <template slot-scope="scope">
                    <span>{{ scope.row.id }}</span>
                </template>
            </el-table-column>
            <el-table-column label="标题" align="center">
                <template slot-scope="scope">
                    <span>{{ scope.row.title }}</span>
                </template>
            </el-table-column>
            <el-table-column label="发布时间" width="200" align="center">
                <template slot-scope="scope">
                    <i class="el-icon-time"></i>
                    <span>{{ scope.row.create_time }}</span>
                </template>
            </el-table-column>
            <el-table-column width="400" label="操作" align="center">
                <template slot-scope="scope">
                    <el-button size="mini" type="primary" icon="el-icon-view"
                        @click="openDetailDialog(scope.row.id)">查询详情</el-button>
                    <el-button size="mini" type="primary" icon="el-icon-view"
                        @click="openCommentDialog(scope.row.id)">查询评论</el-button>
                    <el-button size="mini" type="danger" icon="el-icon-delete" style="margin-left: 10px"
                        @click="clickDelete(scope.row.id)">删除</el-button>
                </template>
            </el-table-column>
        </el-table>

        <el-dialog title="详情" :visible.sync="showDetailDialog" width="50%">
            <el-descriptions direction="vertical" :column="1" border>
                <el-descriptions-item label="标题">{{ detail.title }}</el-descriptions-item>
                <el-descriptions-item label="内容">
                    <span style="white-space: pre-wrap;">{{ detail.content }}</span>
                </el-descriptions-item>
                <el-descriptions-item v-if="detail.type == 10" label="图片">
                    <el-image v-for="(item, index) in detail.image_urls" :key="index" class="article-image" :src="item"
                        fit="cover"></el-image>
                </el-descriptions-item>
                <el-descriptions-item v-else-if="detail.type == 20" label="视频">
                    <el-button type="text" icon="el-icon-view" @click="videoPreview(detail.video_url)">查看</el-button>
                </el-descriptions-item>
            </el-descriptions>
        </el-dialog>

        <el-dialog title="评论" :visible.sync="showCommentDialog" width="70%">
            <el-table :data="commentList" border row-key="id"
                :tree-props="{ children: 'children', hasChildren: 'hasChildren' }">
                <el-table-column label="评论内容">
                    <template slot-scope="scope">
                        <span>{{ scope.row.content }}</span>
                    </template></el-table-column>
                <el-table-column label="用户ID" width="150" align="center">
                    <template slot-scope="scope">
                        <span>{{ scope.row.user_id }}</span>
                    </template>
                </el-table-column>
                <el-table-column label="评论时间" width="150" align="center">
                    <template slot-scope="scope">
                        <span>{{ scope.row.create_time }}</span>
                    </template>
                </el-table-column>
            </el-table>
        </el-dialog>

        <VideoPreview ref="videoPreview"></VideoPreview>
    </div>
</template>

<script>
import VideoPreview from "@/components/VideoPreview/index.vue";
import { getList, detail, getCommentList, del } from '@/api/posts';
export default {
    components: {
        VideoPreview
    },
    data() {
        return {
            list: [],
            listLoading: false,
            tableHeight: window.innerHeight - 95,

            detail: {
            },
            showDetailDialog: false,

            commentList: [],
            showCommentDialog: false,
        };
    },
    created() {
        this.fetchData();
    },
    methods: {
        openDetailDialog(id) {
            this.detail = {};

            detail(id).then((response) => {
                this.detail = response.data;

                this.showDetailDialog = true;
            });
        },
        openCommentDialog(id) {
            this.commentList = {};

            getCommentList(id).then((response) => {
                this.commentList = response.data;

                this.showCommentDialog = true;
            });
        },
        fetchData() {
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

<style scoped>
.article-image {
    width: 105px;
    height: 105px;
    margin: 0px 10px 0px 0px;
}
</style>