import request from '@/utils/request'

export function getList() {
  return request({
    url: '/pointsGoods/getList',
    method: 'get'
  })
}

export function add(data) {
  return request({
    url: '/pointsGoods/add',
    method: 'post',
    data
  })
}

export function edit(data) {
  return request({
    url: '/pointsGoods/edit',
    method: 'post',
    data
  })
}

export function detail(id) {
  return request({
    url: '/pointsGoods/detail',
    method: 'get',
    params: {
      goods_id: id
    }
  })
}


export function del(id) {
  return request({
    url: '/pointsGoods/delete',
    method: 'post',
    data: {
      goods_id: id
    }
  })
}
