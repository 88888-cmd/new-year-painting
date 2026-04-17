import request from '@/utils/request'

export function getList(status, data_v) {
  return request({
    url: '/orderRefund/getList',
    method: 'get',
    params: {
      status,
      data_v
    }
  })
}

export function detail(id, data_v) {
  return request({
    url: '/orderRefund/detail',
    method: 'get',
    params: {
      order_refund_id: id,
      data_v
    }
  })
}

export function firstAudit(order_refund_id, audit_status) {
  return request({
    url: '/orderRefund/firstAudit',
    method: 'post',
    data: {
      order_refund_id,
      audit_status
    }
  })
}

export function receipt(order_refund_id) {
  return request({
    url: '/orderRefund/receipt',
    method: 'post',
    data: {
      order_refund_id
    }
  })
}

export function secondAudit(order_refund_id, audit_status) {
  return request({
    url: '/orderRefund/secondAudit',
    method: 'post',
    data: {
      order_refund_id,
      audit_status
    }
  })
}