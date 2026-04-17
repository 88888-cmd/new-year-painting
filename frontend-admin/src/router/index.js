import Vue from 'vue'
import Router from 'vue-router'

Vue.use(Router)

/* Layout */
import Layout from '@/layout'

export const constantRoutes = [
  {
    path: '/login',
    component: () => import('@/views/login/index'),
    hidden: true
  },

  {
    path: '/404',
    component: () => import('@/views/404'),
    hidden: true
  },

  {
    path: '/',
    component: Layout,
    redirect: '/index',
    children: [{
      path: 'index',
      name: 'Index',
      component: () => import('@/views/index/index'),
      meta: { title: '首页' }
    }]
  },

  {
    path: '/editPassword',
    component: Layout,
    redirect: '/editPassword/index',
    children: [{
      path: 'index',
      name: 'EditPassword',
      component: () => import('@/views/adminUser/editPassword'),
      meta: { title: '修改密码' },
      hidden: true
    }]
  },

  {
    path: '/user',
    component: Layout,
    redirect: '/user',
    children: [{
      path: 'user',
      name: 'User',
      component: () => import('@/views/user/index'),
      meta: { title: '用户管理' }
    }]
  },

  {
    path: '/painting',
    component: Layout,
    redirect: '/painting/list',
    meta: {
      title: '年画管理'
    },
    children: [{
      path: 'list',
      name: 'PaintingList',
      component: () => import('@/views/painting/index'),
      meta: { title: '年画列表' }
    },
    {
      path: 'add',
      name: 'AddPainting',
      component: () => import('@/views/painting/add'),
      meta: { title: '添加年画' },
      hidden: true
    },
    {
      path: 'edit/:id(\\d+)',
      name: 'EditPainting',
      component: () => import('@/views/painting/edit'),
      meta: { title: '编辑年画' },
      hidden: true
    }
    ]
  },

  {
    path: '/posts',
    component: Layout,
    redirect: '/posts/list',
    meta: {
      title: '帖子管理'
    },
    children: [{
      path: 'list',
      name: 'PostsList',
      component: () => import('@/views/posts/index'),
      meta: { title: '帖子列表' }
    },
    {
      path: 'category',
      name: 'PostsCategoryList',
      component: () => import('@/views/posts/category'),
      meta: { title: '帖子分类' }
    },
    ]
  },

  {
    path: '/goods',
    component: Layout,
    redirect: '/goods/list',
    meta: {
      title: '商品管理'
    },
    children: [{
      path: 'list',
      name: 'GoodsList',
      component: () => import('@/views/goods/index'),
      meta: { title: '商品列表' }
    },
    {
      path: 'category',
      name: 'GoodsCategory',
      component: () => import('@/views/goods/category'),
      meta: { title: '商品分类' }
    },
    {
      path: 'add',
      name: 'AddGoods',
      component: () => import('@/views/goods/add'),
      meta: { title: '添加商品' },
      hidden: true
    },
    {
      path: 'edit/:id(\\d+)',
      name: 'EditGoods',
      component: () => import('@/views/goods/edit'),
      meta: { title: '编辑商品' },
      hidden: true
    }
    ]
  },

  {
    path: '/pointsGoods',
    component: Layout,
    redirect: '/pointsGoods/list',
    meta: {
      title: '积分商品管理'
    },
    children: [{
      path: 'list',
      name: 'PointsGoodsList',
      component: () => import('@/views/pointsGoods/index'),
      meta: { title: '积分商品列表' }
    },
    {
      path: 'category',
      name: 'PointsGoodsCategory',
      component: () => import('@/views/pointsGoods/category'),
      meta: { title: '商品分类' }
    },
    {
      path: 'add',
      name: 'AddPointsGoods',
      component: () => import('@/views/pointsGoods/add'),
      meta: { title: '添加商品' },
      hidden: true
    },
    {
      path: 'edit/:id(\\d+)',
      name: 'EditPointsGoods',
      component: () => import('@/views/pointsGoods/edit'),
      meta: { title: '编辑商品' },
      hidden: true
    }
    ]
  },

  {
    path: '/order',
    component: Layout,
    redirect: '/order/list',
    meta: {
      title: '订单管理'
    },
    children: [{
      path: 'list',
      name: 'OrderList',
      component: () => import('@/views/order/index'),
      meta: { title: '订单列表' }
    },
    {
      path: 'refund',
      name: 'RefundList',
      component: () => import('@/views/order/refund'),
      meta: { title: '退款订单' }
    }
    ]
  },

  {
    path: '/module',
    component: Layout,
    redirect: '/module/coupon',
    meta: {
      title: '营销管理'
    },
    children: [{
      path: 'coupon',
      name: 'CouponList',
      component: () => import('@/views/module/coupon/list'),
      meta: { title: '优惠券' }
    },
    {
      path: 'couponLog',
      name: 'CouponLogList',
      component: () => import('@/views/module/coupon/log'),
      meta: { title: '优惠券日志' },
      hidden: true
    },
    {
      path: 'addCoupon',
      name: 'AddCoupon',
      component: () => import('@/views/module/coupon/add'),
      meta: { title: '添加优惠券' },
      hidden: true
    },
    {
      path: 'pointsTask',
      name: 'PointsTask',
      component: () => import('@/views/module/pointsTask/list'),
      meta: { title: '积分任务' }
    },
    {
      path: 'addPointsTask',
      name: 'AddPointsTask',
      component: () => import('@/views/module/pointsTask/add'),
      meta: { title: '添加积分任务' },
      hidden: true
    },
    {
      path: 'editPointsTask/:id(\\d+)',
      name: 'EditPointsTask',
      component: () => import('@/views/module/pointsTask/edit'),
      meta: { title: '编辑积分任务' },
      hidden: true
    }
    ]
  },

  {
    path: '/paintingCalendar',
    component: Layout,
    redirect: '/paintingCalendar',
    children: [{
      path: 'paintingCalendar',
      name: 'PaintingCalendar',
      component: () => import('@/views/paintingCalendar/index'),
      meta: { title: '年画日历' }
    }]
  },

  {
    path: '/banner',
    component: Layout,
    redirect: '/banner/list',
    meta: {
      title: '轮播图管理'
    },
    children: [{
      path: 'list',
      name: 'BannerList',
      component: () => import('@/views/banner/list'),
      meta: { title: '轮播图列表' }
    },
    {
      path: 'articleContent/:id(\\d+)',
      name: 'BannerSetArticleContent',
      component: () => import('@/views/banner/articleContent'),
      meta: { title: '文章内容' },
      hidden: true
    }
    ]
  },

  {
    path: '/setting',
    component: Layout,
    redirect: '/setting/index',
    meta: {
      title: '设置'
    },
    children: [{
      path: 'index',
      name: 'SettingPoints',
      component: () => import('@/views/setting/points'),
      meta: { title: '积分设置' }
    },
    {
      path: 'freightTemp',
      name: 'FreightTemp',
      component: () => import('@/views/setting/freightTemp'),
      meta: { title: '运费模板' }
    },
    {
      path: 'addFreightTemp',
      name: 'addFreightTemp',
      component: () => import('@/views/setting/addFreightTemp'),
      meta: { title: '添加运费模板' },
      hidden: true
    },
    {
      path: 'editFreightTemp/:id(\\d+)',
      name: 'EditFreightTemp',
      component: () => import('@/views/setting/editFreightTemp'),
      meta: { title: '编辑运费模板' },
      hidden: true
    }
    ]
  },

  // 404 page must be placed at the end !!!
  { path: '*', redirect: '/404', hidden: true }
]

const createRouter = () => new Router({
  // mode: 'history', // require service support
  scrollBehavior: () => ({ y: 0 }),
  routes: constantRoutes
})

const router = createRouter()

export function resetRouter() {
  const newRouter = createRouter()
  router.matcher = newRouter.matcher // reset router
}

export default router
