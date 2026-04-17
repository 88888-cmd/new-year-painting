<template>
    <div class="app-container">
        <el-tabs v-model="tab" @tab-click="clickTab">
            <el-tab-pane label="待处理" name="0"></el-tab-pane>
            <el-tab-pane label="已处理" name="1"></el-tab-pane>
        </el-tabs>
        <el-table ref="multipleTable" v-loading="listLoading" :data="list" :height="tableHeight"
            element-loading-text="Loading" border fit highlight-current-row>
            <el-table-column label="用户ID" align="center" width="200">
                <template slot-scope="scope">
                    <span>{{ scope.row.user_id }}</span>
                </template>
            </el-table-column>
            <el-table-column label="订单号" align="center">
                <template slot-scope="scope">
                    <span>{{ scope.row.relation_order_no }}</span>
                </template>
            </el-table-column>
            <el-table-column label="退款单号" align="center">
                <template slot-scope="scope">
                    <span>{{ scope.row.refund_no }}</span>
                </template>
            </el-table-column>
            <el-table-column label="状态" width="160" align="center">
                <template slot-scope="scope">
                    <template v-if="scope.row.refund_type == 1">
                        <span v-if="scope.row.status == 1">
                            <span v-if="scope.row.audit_status == 1">
                                待审核
                            </span>
                        </span>
                        <span v-else>
                            {{ scope.row.status_display }}
                        </span>
                    </template>
                    <template v-else-if="scope.row.refund_type == 2">
                        <span v-if="scope.row.status == 1">
                            <span v-if="scope.row.audit_status == 1">
                                待审核
                            </span>
                            <span v-if="scope.row.audit_status == 2 && scope.row.is_user_send == 0">
                                待用户退回
                            </span>
                            <span
                                v-if="scope.row.audit_status == 2 && scope.row.is_user_send == 1 && scope.row.is_receipt == 0">
                                待平台确认收到退货
                            </span>
                            <span
                                v-if="scope.row.audit_status == 2 && scope.row.is_user_send == 1 && scope.row.is_receipt == 1">
                                待平台确认退款
                            </span>
                            <span v-if="scope.row.audit_status == 3">
                                已拒绝
                            </span>
                        </span>
                        <span v-else>
                            {{ scope.row.status_display }}
                        </span>
                    </template>
                </template>
            </el-table-column>
            <el-table-column label="申请时间" width="200" align="center">
                <template slot-scope="scope">
                    <i class="el-icon-time" />
                    <span>{{ scope.row.create_time }}</span>
                </template>
            </el-table-column>
            <el-table-column width="130" label="操作" align="center">
                <template slot-scope="scope">
                    <el-button size="mini" type="primary" icon="el-icon-view"
                        @click="openDetailDialog(scope.row.id)">详情</el-button>
                </template>
            </el-table-column>
        </el-table>

        <el-dialog title="订单详情" :visible.sync="showDetailDialog" width="70%">
            <template v-if="showDetailDialog">
                <aside>基础信息</aside>
                <el-table :data="[{}]" border style="margin-bottom: 20px">
                    <el-table-column label="申请时间" align="center" width="200">{{ detail.detail.create_time
                        }}</el-table-column>
                    <el-table-column label="退款类型" align="center" width="200">{{ detail.detail.refund_type_display
                    }}</el-table-column>
                    <el-table-column label="用户申请原因" align="center">{{ detail.detail.apply_desc || '未填写'
                    }}</el-table-column>
                    <el-table-column label="售后单状态" align="center">{{ detail.detail.status_display
                    }}</el-table-column>
                </el-table>

                <template v-if="detail.detail.apply_image_urls.length">
                    <aside>用户上传图片</aside>
                    <el-image v-for="(item, index) in detail.detail.apply_image_urls" :key="index" class="grid-image"
                        :src="item" fit="cover"></el-image>
                </template>

                <aside>商品信息</aside>
                <el-table :data="detail.order_goods_list" border style="margin-bottom: 20px">
                    <el-table-column label="商品图片" width="150" align="center">
                        <template slot-scope="scope">
                            <el-avatar shape="square" :size="40" :src="scope.row.goods_image_url" />
                        </template>
                    </el-table-column>
                    <el-table-column label="商品名称">
                        <template slot-scope="scope">
                            {{ scope.row.goods_name }}
                        </template>
                    </el-table-column>
                    <el-table-column label="规格" width="120" align="center">
                        <template slot-scope="scope">
                            <span>{{ scope.row.goods_sku_name }}</span>
                        </template>
                    </el-table-column>
                    <el-table-column v-if="detail.detail.relation_order_type == 1" label="商品价格(单价)" width="150"
                        align="center">
                        <template slot-scope="scope">
                            <span>¥{{ scope.row.goods_sku_price }}</span>
                        </template>
                    </el-table-column>
                    <el-table-column v-if="detail.detail.relation_order_type == 2" label="商品积分" width="150"
                        align="center">
                        <template slot-scope="scope">
                            <span>{{ scope.row.goods_sku_point_num }}</span>
                        </template>
                    </el-table-column>
                    <el-table-column label="运费" width="100" align="center">
                        <template slot-scope="scope">
                            <span>¥{{ scope.row.freight_price }}</span>
                        </template>
                    </el-table-column>
                    <el-table-column label="购买数量" width="130" align="center">
                        <template slot-scope="scope">
                            {{ scope.row.buy_num }}
                        </template>
                    </el-table-column>
                    <el-table-column v-if="detail.detail.relation_order_type == 1" label="数据" align="center">
                        <template slot-scope="scope">
                            <div>优惠券抵扣：¥{{ scope.row.normal_order_allocated_data['coupon_deduct'] }}</div>
                            <div>普通积分抵扣：¥{{ scope.row.normal_order_allocated_data['normal_points_deduct'] }}</div>
                            <div>总金额：¥{{ scope.row.normal_order_allocated_data['total_price'] }}</div>
                        </template>
                    </el-table-column>
                </el-table>

                <template v-if="detail.detail.is_user_send == 1">
                    <aside>用户退货信息</aside>
                    <el-table :data="[{}]" border style="margin-bottom: 20px">
                        <el-table-column label="退货快递时间" align="center">{{ detail.detail.send_time
                        }}</el-table-column>
                        <el-table-column label="快递公司名称" align="center">{{ detail.detail.express_name
                        }}</el-table-column>
                        <el-table-column label="快递单号" align="center">{{ detail.detail.express_no
                        }}</el-table-column>
                    </el-table>
                </template>

                <template v-if="detail.detail.status == 3">
                    <aside>退款信息</aside>
                    <el-table v-if="detail.detail.relation_order_type == 1" :data="[{}]" border
                        style="margin-bottom: 20px">
                        <el-table-column label="退款金额" align="center">¥{{ detail.detail.refund_money
                        }}</el-table-column>
                        <el-table-column label="优惠券" align="center">{{ detail.detail.refund_coupon == 1 ?
                            '退回' : '不退回'
                            }}</el-table-column>
                        <el-table-column label="普通积分" align="center">
                            <span v-if="detail.detail.refund_normal_points > 0">{{ detail.detail.refund_normal_points
                                }}</span>
                            <span v-else>不退款</span>
                        </el-table-column>
                    </el-table>
                    <el-table v-else-if="detail.detail.relation_order_type == 2" :data="[{}]" border
                        style="margin-bottom: 20px">
                        <el-table-column label="普通积分" align="center">
                            <span v-if="detail.detail.refund_normal_points > 0">{{ detail.detail.refund_normal_points
                                }}</span>
                            <span v-else>不退款</span>
                        </el-table-column>
                        <el-table-column label="文化积分" align="center">
                            <span v-if="detail.detail.refund_cultural_points > 0">{{
                                detail.detail.refund_cultural_points
                                }}</span>
                            <span v-else>不退款</span>
                        </el-table-column>
                    </el-table>
                </template>

                <aside style="margin-bottom: 20px;">进度</aside>
                <div v-if="detail.detail.refund_type == 1" style="height: 200px;">
                    <el-steps direction="vertical" :active="stepActive">
                        <el-step title="用户提交申请" />
                        <el-step title="平台审核">
                            <template slot="description">
                                <span v-if="detail.detail.audit_status == 1 && detail.detail.status != 4">
                                    <el-button size="mini" type="primary" @click="clickAcceptFirst">通过</el-button>
                                    <el-button size="mini" type="danger" @click="clickRejectFirst">拒绝</el-button>
                                </span>
                                <span v-if="detail.detail.audit_status == 2">已通过审核</span>
                                <span v-if="detail.detail.audit_status == 3">已拒绝</span>
                            </template>
                        </el-step>
                        <el-step :title="detail.detail.status == 4 ? '已取消' : '处理完成'"
                            :description="detail.detail.status == 4 ? '用户已取消申请' : ''" />
                    </el-steps>
                </div>
                <div v-else-if="detail.detail.refund_type == 2" style="height: 300px;">
                    <el-steps v-if="detail.detail.refund_type == 2" direction="vertical" :active="stepActive">
                        <el-step title="用户提交申请" />
                        <el-step title="平台审核">
                            <template slot="description">
                                <span v-if="detail.detail.audit_status == 1 && detail.detail.status != 4">
                                    <el-button size="mini" type="primary" @click="clickAcceptFirst">通过</el-button>
                                    <el-button size="mini" type="danger" @click="clickRejectFirst">拒绝</el-button>
                                </span>
                                <span v-if="detail.detail.audit_status == 2">已通过审核</span>
                                <span v-if="detail.detail.audit_status == 3">已拒绝</span>
                            </template>
                        </el-step>

                        <template v-if="detail.detail.status != 4">
                            <el-step title="用户退回商品">
                                <template slot="description">
                                    <span
                                        v-if="detail.detail.is_user_send == 0 && detail.detail.audit_status == 2">待用户退回</span>
                                    <span v-if="detail.detail.is_user_send == 1">已退回商品</span>
                                </template>
                            </el-step>
                            <el-step title="平台确认收货">
                                <template slot="description">
                                    <span v-if="detail.detail.is_receipt == 0 && detail.detail.is_user_send == 1">
                                        <el-button size="mini" type="primary" @click="confirmReceipt">确认收到</el-button>
                                    </span>
                                    <span v-if="detail.detail.is_receipt == 1">已确认收到退货</span>
                                </template>
                            </el-step>
                            <el-step title="平台确认退款">
                                <template slot="description">
                                    <span v-if="detail.detail.is_receipt == 1 && detail.detail.status == 1">
                                        <el-button size="mini" type="primary"
                                            @click="clickAcceptSecond">确认退款</el-button>
                                        <el-button size="mini" type="danger" @click="clickRejectSecond">拒绝退款</el-button>
                                    </span>
                                    <span v-if="detail.detail.status == 3">退款已完成</span>
                                    <span v-if="detail.detail.status == 2">已拒绝退款</span>
                                </template>
                            </el-step>
                        </template>

                        <el-step v-if="detail.detail.status == 4" title="已取消" description="用户已取消退款申请" />
                    </el-steps>
                </div>
            </template>
        </el-dialog>
    </div>
</template>

<script>
import { getList, detail, firstAudit, receipt, secondAudit } from '@/api/orderRefund';
export default {
    data() {
        return {
            tab: '0',

            list: [],
            dataV: 0,
            listLoading: false,
            tableHeight: window.innerHeight - 145,

            showDetailDialog: false,
            detail: {},
            detailDataV: 0,
        };
    },
    created() {
        this.fetchData();
    },
    computed: {
        stepActive() {
            if (!this.showDetailDialog) return 0;

            const { refund_type, status, audit_status, is_user_send, is_receipt } = this.detail.detail;

            if (status === 4) {
                return this.getStepCount() - 1;
            }

            if (refund_type === 1) {
                if (status === 1) {
                    return audit_status === 1 ? 1 : 2;
                }
                return 3;
            }

            if (refund_type === 2) {
                if (audit_status === 1) return 1;
                if (audit_status === 3) return 2;

                if (audit_status === 2) {
                    if (is_user_send === 0) return 2;
                    if (is_user_send === 1 && is_receipt === 0) return 3;
                    if (is_receipt === 1 && status === 1) return 4;
                    if (status === 3) return 5;
                }
            }

            return 0;
        }
    },
    methods: {
        clickAcceptSecond() {
            let that = this;

            const detailDataV = that.detailDataV;
            const order_refund_id = that.detail.detail.id;
            const refund_no = that.detail.detail.refund_no;

            that.$confirm("确定通过审核吗?", `退款单号：${refund_no}`, {
                confirmButtonText: "确定",
                cancelButtonText: "取消",
                type: "warning",
            }).then(() => {
                secondAudit(order_refund_id, 2).then(response => {
                    if (detailDataV == that.detailDataV) {
                        that.auditAfterDetial(order_refund_id, detailDataV);
                    }

                    that.$message({
                        message: "操作成功",
                        type: "success",
                    });
                })
            });
        },
        clickRejectSecond() {
            let that = this;

            const detailDataV = that.detailDataV;
            const order_refund_id = that.detail.detail.id;
            const refund_no = that.detail.detail.refund_no;

            that.$confirm("确定不通过审核吗?", `退款单号：${refund_no}`, {
                confirmButtonText: "确定",
                cancelButtonText: "取消",
                type: "warning"
            }).then(() => {
                secondAudit(order_refund_id, 3).then(response => {
                    if (detailDataV == that.detailDataV) {
                        that.auditAfterDetial(order_refund_id, detailDataV);
                    }

                    that.$message({
                        message: "操作成功",
                        type: "success",
                    });
                })
            });
        },
        confirmReceipt() {
            this.$confirm('确定已收到退货吗?', '确认收货', {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                type: 'info'
            }).then(() => {
                const detailDataV = this.detailDataV;

                receipt(this.detail.detail.id).then(response => {
                    if (detailDataV == this.detailDataV) {
                        this.auditAfterDetial(this.detail.detail.id, detailDataV);
                    }

                    this.$message({
                        message: "确认收货成功",
                        type: "success",
                    });
                });
            });
        },
        getStepCount() {
            const { refund_type, status } = this.detail.detail;
            if (status === 4) {
                return refund_type === 1 ? 3 : 4;
            }
            return refund_type === 1 ? 3 : 5;
        },
        auditAfterDetial(order_refund_id, detailDataV) {
            let that = this;

            detail(order_refund_id, detailDataV).then((response) => {
                if (detailDataV == response.data.data_v) {
                    that.detail = response.data;
                }
            });
        },
        clickAcceptFirst() {
            let that = this;

            const detailDataV = that.detailDataV;
            const order_refund_id = that.detail.detail.id;
            const refund_no = that.detail.detail.refund_no;

            that.$confirm("确定通过审核吗?", `退款单号：${refund_no}`, {
                confirmButtonText: "确定",
                cancelButtonText: "取消",
                type: "warning",
            }).then(() => {
                firstAudit(order_refund_id, 2).then(response => {
                    if (detailDataV == that.detailDataV) {
                        that.auditAfterDetial(order_refund_id, detailDataV);
                    }

                    that.$message({
                        message: "操作成功",
                        type: "success",
                    });
                })
            });
        },
        clickRejectFirst() {
            let that = this;

            const detailDataV = that.detailDataV;
            const order_refund_id = that.detail.detail.id;
            const refund_no = that.detail.detail.refund_no;

            that.$confirm("确定不通过审核吗?", `退款单号：${refund_no}`, {
                confirmButtonText: "确定",
                cancelButtonText: "取消",
                type: "warning"
            }).then(() => {
                firstAudit(order_refund_id, 3).then(response => {
                    if (detailDataV == that.detailDataV) {
                        that.auditAfterDetial(order_refund_id, detailDataV);
                    }

                    that.$message({
                        message: "操作成功",
                        type: "success",
                    });
                })
            });
        },
        openDetailDialog(id) {
            let that = this;

            that.detailDataV++;

            Object.assign(this.$data.detail, this.$options.data().detail);

            detail(id, that.detailDataV).then((response) => {
                if (that.detailDataV != response.data.data_v) return;

                that.detail = response.data;

                that.showDetailDialog = true;
            });
        },
        fetchData() {
            let that = this;

            that.dataV++;

            that.listLoading = true;

            getList(that.tab, that.dataV).then((response) => {
                if (that.dataV == response.data.data_v) {
                    that.list = response.data.list;
                    that.listLoading = false;
                }
            });
        },
        clickTab() {
            this.list = [];
            this.fetchData();

            console.log('tab', this.tab)
        },
    },
};
</script>

<style scoped>
.grid-image {
    width: 105px;
    height: 105px;
    margin: 0px 10px 0px 0px;
}
</style>