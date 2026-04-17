import request from '@/utils/request'

export function getList(status, data_v) {
  return request({
    url: '/order/getList',
    method: 'get',
    params: {
      status,
      data_v
    }
  })
}

export function detail(id, data_v) {
  return request({
    url: '/order/detail',
    method: 'get',
    params: {
      order_id: id,
      data_v
    }
  })
}

export function delivery(form) {
  return request({
    url: '/order/delivery',
    method: 'post',
    data: form
  })
}
