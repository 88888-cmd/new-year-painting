import request from '@/utils/request'

export function getList() {
  return request({
    url: '/coupon/getList',
    method: 'get'
  })
}

export function getLogList() {
  return request({
    url: '/coupon/getLogList',
    method: 'get'
  })
}

export function add(data) {
  return request({
    url: '/coupon/add',
    method: 'post',
    data
  })
}

export function del(id) {
  return request({
    url: '/coupon/delete',
    method: 'post',
    data: {
      coupon_id: id
    }
  })
}
