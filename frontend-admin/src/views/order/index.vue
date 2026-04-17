<template>
    <div class="app-container">
        <el-tabs v-model="tab" @tab-click="clickTab">
            <el-tab-pane label="全部" name="0"></el-tab-pane>
            <el-tab-pane label="待发货" name="1"></el-tab-pane>
            <el-tab-pane label="待收货" name="2"></el-tab-pane>
            <el-tab-pane label="已完成" name="3"></el-tab-pane>
            <el-tab-pane label="已关闭" name="4"></el-tab-pane>
        </el-tabs>
        <el-table ref="multipleTable" v-loading="listLoading" :data="list" :height="tableHeight"
            element-loading-text="Loading" border fit highlight-current-row>
            <el-table-column label="用户ID" align="center" width="200">
                <template slot-scope="scope">
                    <span>{{ scope.row.user_id }}</span>
                </template>
            </el-table-column>
            <el-table-column label="订单类型" align="center" width="200">
                <template slot-scope="scope">
                    <span v-if="scope.row.order_type == 1">普通商城订单</span>
                    <span v-else-if="scope.row.order_type == 2">积分商城订单</span>
                </template>
            </el-table-column>
            <el-table-column label="订单号" align="center">
                <template slot-scope="scope">
                    <span>{{ scope.row.order_no }}</span>
                </template>
            </el-table-column>
            <!-- <el-table-column label="实付金额" align="center" width="200">
                <template slot-scope="scope">
                    <span>{{ scope.row.pay_price }}</span>
                </template>
            </el-table-column> -->
            <el-table-column label="订单状态" width="160" align="center">
                <template slot-scope="scope">
                    <span>
                        {{ scope.row.order_status_display }}
                    </span>
                </template>
            </el-table-column>
            <el-table-column label="下单时间" width="200" align="center">
                <template slot-scope="scope">
                    <i class="el-icon-time" />
                    <span>{{ scope.row.create_time }}</span>
                </template>
            </el-table-column>
            <el-table-column width="230" label="操作" align="center">
                <template slot-scope="scope">
                    <el-button size="mini" type="primary" icon="el-icon-view"
                        @click="openDetailDialog(scope.row.id)">详情</el-button>
                    <el-button :disabled="scope.row.order_status != 1" size="mini" type="warning"
                        icon="el-icon-edit-outline" @click="clickDelivery(scope.row.id)">发货</el-button>
                </template>
            </el-table-column>
        </el-table>

        <el-dialog title="订单详情" :visible.sync="showDetailDialog" width="70%">
            <template v-if="showDetailDialog">
                <aside>基础信息</aside>
                <el-table :data="[{}]" border style="margin-bottom: 20px">
                    <el-table-column label="下单用户" align="center" width="200">{{ detail.order.user_id
                    }}</el-table-column>
                    <el-table-column label="订单号" align="center">{{ detail.order.order_no }}</el-table-column>
                    <el-table-column label="订单状态" align="center">
                        {{ detail.order.order_status_display }}
                    </el-table-column>
                    <el-table-column label="下单时间" align="center">{{ detail.order.create_time }}</el-table-column>
                    <el-table-column v-if="detail.order.delivery_time.length" label="发货时间" align="center">{{
                        detail.order.delivery_time }}</el-table-column>
                    <el-table-column v-if="detail.order.receipt_time.length" label="收货时间" align="center">{{
                        detail.order.receipt_time }}</el-table-column>
                </el-table>

                <aside>订单支付</aside>
                <el-table v-if="detail.order.order_type == 1" :data="[{}]" border style="margin-bottom: 20px">
                    <el-table-column label="总金额" align="center">¥{{ detail.order.total_price
                        }}</el-table-column>
                    <el-table-column label="总运费" align="center">¥{{ detail.order.freight_price
                        }}</el-table-column>
                    <el-table-column label="优惠券抵扣" align="center">¥{{ detail.order.coupon_money
                        }}</el-table-column>
                    <el-table-column label="使用普通积分" align="center">{{ detail.order.normal_points
                        }}</el-table-column>
                    <el-table-column v-if="detail.order.normal_points > 0" label="普通积分抵扣" align="center">¥{{
                        detail.order.normal_points_deduct
                    }}</el-table-column>
                    <el-table-column label="支付金额" align="center">¥{{ detail.order.pay_price }}</el-table-column>
                </el-table>
                <el-table v-else-if="detail.order.order_type == 2" :data="[{}]" border style="margin-bottom: 20px">
                    <el-table-column label="总积分" align="center">{{ detail.order.total_points }}</el-table-column>
                    <el-table-column label="使用普通积分" align="center">{{ detail.order.normal_points }}</el-table-column>
                    <el-table-column label="使用文化积分" align="center">{{ detail.order.cultural_points }}</el-table-column>
                </el-table>

                <template v-if="detail.order.delivery_time.length">
                    <aside>发货信息</aside>
                    <el-table :data="[{}]" border style="margin-bottom: 20px">
                        <el-table-column label="快递公司名称" align="center">{{ detail.order.express_name
                            }}</el-table-column>
                        <el-table-column label="快递单号" align="center">{{ detail.order.express_no
                            }}</el-table-column>
                    </el-table>
                </template>

                <aside>收货信息</aside>
                <el-table :data="[{}]" border style="margin-bottom: 20px">
                    <el-table-column label="姓名" align="center" width="200">{{ detail.address.name }}</el-table-column>
                    <el-table-column label="手机号" align="center" width="200">{{ detail.address.phone }}</el-table-column>
                    <el-table-column label="地区" align="center" width="200">{{ detail.address.province }}-{{
                        detail.address.city
                        }}-{{ detail.address.district }}</el-table-column>
                    <el-table-column label="详细地址" align="center">{{ detail.address.detail }}</el-table-column>
                </el-table>

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
                    <el-table-column v-if="detail.order.order_type == 1" label="商品价格(单价)" width="150" align="center">
                        <template slot-scope="scope">
                            <span>¥{{ scope.row.goods_sku_price }}</span>
                        </template>
                    </el-table-column>
                    <el-table-column v-if="detail.order.order_type == 2" label="商品积分" width="150" align="center">
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
                    <el-table-column label="状态" width="150" align="center">
                        <template slot-scope="scope">
                            <span v-if="scope.row.status == 1">正常</span>
                            <span v-else-if="scope.row.status == 2">申请退款中</span>
                            <span v-else-if="scope.row.status == 3">已退款</span>
                        </template>
                    </el-table-column>
                    <el-table-column v-if="detail.order.order_type == 1" label="数据" align="center">
                        <template slot-scope="scope">
                            <div>优惠券抵扣：¥{{ scope.row.normal_order_allocated_data['coupon_deduct'] }}</div>
                            <div>普通积分抵扣：¥{{ scope.row.normal_order_allocated_data['normal_points_deduct'] }}</div>
                            <div>总金额：¥{{ scope.row.normal_order_allocated_data['total_price'] }}</div>
                        </template>
                    </el-table-column>
                </el-table>
            </template>
        </el-dialog>

        <el-dialog title="表单" width="30%" :visible.sync="showDeliveryDialog">
            <el-form :model="deliveryForm">
                <el-form-item label="快递公司名称">
                    <el-input v-model="deliveryForm.express_name" maxlength="255"></el-input>
                </el-form-item>
                <el-form-item label="快递单号">
                    <el-input v-model="deliveryForm.express_no" maxlength="255"></el-input>
                </el-form-item>
            </el-form>
            <div slot="footer" class="dialog-footer">
                <el-button @click="showDeliveryDialog = false">取消</el-button>
                <el-button type="primary" @click="clickSubmitDeliveryForm">确定</el-button>
            </div>
        </el-dialog>
    </div>
</template>

<script>
import { getList, detail, delivery } from '@/api/order';
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

            showDeliveryDialog: false,
            deliveryForm: {
                order_id: 0,
                express_name: '',
                express_no: ''
            }
        };
    },
    created() {
        this.fetchData();
    },
    methods: {
        clickSubmitDeliveryForm() {
            let that = this;

            const order_id = that.deliveryForm.order_id;

            delivery(that.deliveryForm).then((response) => {
                Object.assign(that.$data.deliveryForm, that.$options.data().deliveryForm);
                that.showDeliveryDialog = false;

                const index = that.list.findIndex(item => item.id == order_id);
                if (index > -1) {
                    that.$set(that.list[index], 'order_status', 2);
                }

                that.$message({
                    message: "操作成功",
                    type: "success",
                });
            });
        },
        clickDelivery(id) {
            Object.assign(this.$data.deliveryForm, this.$options.data().deliveryForm);
            this.deliveryForm.order_id = id;
            this.showDeliveryDialog = true;
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