import 'package:app/pages/addAddress/view.dart';
import 'package:app/pages/addPosts/view.dart';
import 'package:app/pages/addStoryPosts/view.dart';
import 'package:app/pages/articleContent/view.dart';
import 'package:app/pages/goodsComment/view.dart';
import 'package:app/pages/pointsGoodsComment/view.dart';
import 'package:app/pages/submitWish/view.dart';
import 'package:app/pages/address/view.dart';
import 'package:app/pages/aiChat/view.dart';
import 'package:app/pages/aiImageEdit/view.dart';
import 'package:app/pages/aiStoryPage/view.dart';
import 'package:app/pages/aiText2Image/view.dart';
import 'package:app/pages/applyRefund/view.dart';
import 'package:app/pages/cart/view.dart';
import 'package:app/pages/commentOrderGoods/view.dart';
import 'package:app/pages/completeProfile/view.dart';
import 'package:app/pages/coupon/view.dart';
import 'package:app/pages/editAddress/view.dart';
import 'package:app/pages/goodsDetail/view.dart';
import 'package:app/pages/language/view.dart';
import 'package:app/pages/myCounpon/view.dart';
import 'package:app/pages/myFavorite/view.dart';
import 'package:app/pages/myOrderList/view.dart';
import 'package:app/pages/myPosts/view.dart';
import 'package:app/pages/myView/view.dart';
import 'package:app/pages/orderDetail/view.dart';
import 'package:app/pages/orderRefundDelivery/view.dart';
import 'package:app/pages/orderRefundDetail/view.dart';
import 'package:app/pages/painting/view.dart';
import 'package:app/pages/paintingCalendar/view.dart';
import 'package:app/pages/paintingDetail/view.dart';
import 'package:app/pages/pointsGoodsDetail/view.dart';
import 'package:app/pages/pointsShop/view.dart';
import 'package:app/pages/ponits/view.dart';
import 'package:app/pages/postsDetail/view.dart';
import 'package:app/pages/register/view.dart';
import 'package:app/pages/searchGoods/view.dart';
import 'package:app/pages/searchPainting/view.dart';
import 'package:app/pages/searchPosts/view.dart';
import 'package:app/pages/selectAddress/view.dart';
import 'package:app/pages/selectInterests/view.dart';
import 'package:app/pages/selectPainting/view.dart';
import 'package:app/pages/setting/view.dart';
import 'package:app/pages/shop/view.dart';
import 'package:app/pages/submitOrder/view.dart';
import 'package:app/pages/submitPointOrder/view.dart';
import 'package:app/pages/changePassword/view.dart';
import 'package:app/pages/updateProfile/view.dart';
import 'package:app/pages/wish/view.dart';
import 'package:get/route_manager.dart';
import 'package:app/pages/splash.dart';
import 'package:app/pages/login/view.dart';
import 'package:app/pages/main/view.dart';
import 'package:app/pages/addStoryPostsFirst/view.dart';

class Routes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const completeProfile = '/completeProfile';
  static const selectInterests = '/selectInterests';
  static const main = '/main';
  static const paintingDetail = '/paintingDetail';
  static const addPosts = '/addPosts';
  static const addStoryPostsFirst = '/addStoryPostsFirst';
  static const addStoryPosts = '/addStoryPosts';
  static const postsDetail = '/postsDetail';
  static const aiStory = '/aiStory';
  static const shop = '/shop';
  static const coupon = '/coupon';
  static const points = '/points';
  static const pointsShop = '/pointsShop';
  static const pointsGoodsDetail = '/pointsGoodsDetail';
  static const goodsDetail = '/goodsDetail';
  static const cart = '/cart';
  static const paintingCalendar = '/paintingCalendar';
  static const submitOrder = '/submitOrder';
  static const myOrderList = '/myOrderList';
  static const wish = '/wish';
  static const address = '/address';
  static const setting = '/setting';
  static const myCoupon = '/myCoupon';
  static const orderDetail = '/orderDetail';
  static const applyRefund = '/applyRefund';
  static const commentOrderGoods = '/commentOrderGoods';
  static const submitWish = '/submitWish';
  static const selectPainting = '/selectPainting';
  static const addAddress = '/addAddress';
  static const myPosts = '/myPosts';
  static const searchPainting = '/searchPainting';
  static const searchGoods = '/searchGoods';
  static const searchPosts = '/searchPosts';
  static const aiChat = '/aiChat';
  static const aiText2Image = '/aiText2Image';
  static const aiImageEdit = '/aiImageEdit';
  static const painting = '/painting';
  static const editAddress = '/editAddress';
  static const selectAddress = '/selectAddress';
  static const refundOrderDetail = '/refundOrderDetail';
  static const submitPointOrder = '/submitPointOrder';
  static const orderRefundDetail = '/orderRefundDetail';
  static const orderRefundDelivery = '/orderRefundDelivery';
  static const updateProfile = '/updateProfile';
  static const language = '/language';
  static const changePassword = '/changePassword';
  static const myFavorited = '/myFavorited';
  static const myView = '/myView';
  static const goodsComment = '/goodsComment';
  static const pointsGoodsComment = '/pointsGoodsComment';
  static const articleContent = '/articleContent';

  static final List<GetPage> pages = [
    GetPage(name: splash, page: () => const SplashPage()),
    GetPage(name: login, page: () => const LoginPage()),
    GetPage(name: register, page: () => const RegisterPage()),
    GetPage(name: completeProfile, page: () => const CompleteProfilePage()),
    GetPage(name: selectInterests, page: () => const SelectInterestsPage()),
    GetPage(name: main, page: () => const MainPage()),
    GetPage(name: paintingDetail, page: () => const PaintingDetailPage()),
    GetPage(name: addPosts, page: () => const AddPostsPage()),
    GetPage(
      name: addStoryPostsFirst,
      page: () => const AddStoryPostsFirstPage(),
    ),
    GetPage(name: addStoryPosts, page: () => const AddStoryPostsPage()),
    GetPage(name: postsDetail, page: () => const PostsDetailPage()),
    GetPage(name: aiStory, page: () => const AIStoryPage()),
    GetPage(name: shop, page: () => const ShopPage()),
    GetPage(name: coupon, page: () => const CouponPage()),
    GetPage(name: points, page: () => const PointsPage()),
    GetPage(name: pointsShop, page: () => const PointsShopPage()),
    GetPage(name: pointsGoodsDetail, page: () => const PointsGoodsDetailPage()),
    GetPage(name: goodsDetail, page: () => const GoodsDetailPage()),
    GetPage(name: cart, page: () => const CartPage()),
    GetPage(name: paintingCalendar, page: () => const PaintingCalendarPage()),
    GetPage(name: submitOrder, page: () => const SubmitOrderPage()),
    GetPage(name: myOrderList, page: () => const MyOrderList()),
    GetPage(name: wish, page: () => const WishPage()),
    GetPage(name: address, page: () => const AddressPage()),
    GetPage(name: setting, page: () => const SettingPage()),
    GetPage(name: myCoupon, page: () => const MyCouponPage()),
    GetPage(name: orderDetail, page: () => const OrderDetailPage()),
    GetPage(name: applyRefund, page: () => const ApplyRefundPage()),
    GetPage(name: commentOrderGoods, page: () => const CommentOrderGoodsPage()),
    GetPage(name: submitWish, page: () => const SubmitWishPage()),
    GetPage(name: selectPainting, page: () => const SelectPaintingPage()),
    GetPage(name: addAddress, page: () => const AddAddressPage()),
    GetPage(name: myPosts, page: () => const MyPostsPage()),
    GetPage(name: searchPainting, page: () => const SearchPaintingPage()),
    GetPage(name: searchGoods, page: () => const SearchGoodsPage()),
    GetPage(name: searchPosts, page: () => const SearchPostsPage()),
    GetPage(name: aiChat, page: () => const AIChatPage()),
    GetPage(name: aiText2Image, page: () => const AIText2ImagePage()),
    GetPage(name: aiImageEdit, page: () => const AIImageEditPage()),
    GetPage(name: painting, page: () => const PaintingPage()),
    GetPage(name: editAddress, page: () => const EditAddressPage()),
    GetPage(name: selectAddress, page: () => const SelectAddressPage()),
    GetPage(name: submitPointOrder, page: () => const SubmitPointOrderPage()),
    GetPage(name: orderRefundDetail, page: () => const OrderRefundDetailPage()),
    GetPage(
      name: orderRefundDelivery,
      page: () => const OrderRefundDeliveryPage(),
    ),
    GetPage(name: updateProfile, page: () => const UpdateProfilePage()),
    GetPage(name: language, page: () => const LanguagePage()),
    GetPage(name: changePassword, page: () => const ChangePasswordPage()),
    GetPage(name: myFavorited, page: () => const MyFavoritedPage()),
    GetPage(name: myView, page: () => const MyViewPage()),
    GetPage(name: goodsComment, page: () => const GoodsCommentPage()),
    GetPage(
      name: pointsGoodsComment,
      page: () => const PointsGoodsCommentPage(),
    ),
    GetPage(name: articleContent, page: () => const ArticleContentPage()),
  ];
}
