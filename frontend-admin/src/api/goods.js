import request from '@/utils/request'

export function getList() {
  return request({
    url: '/goods/getList',
    method: 'get'
  })
}

export function add(data) {
  return request({
    url: '/goods/add',
    method: 'post',
    data
  })
}

export function edit(data) {
  return request({
    url: '/goods/edit',
    method: 'post',
    data
  })
}

export function detail(id) {
  return request({
    url: '/goods/detail',
    method: 'get',
    params: {
      goods_id: id
    }
  })
}


export function del(id) {
  return request({
    url: '/goods/delete',
    method: 'post',
    data: {
      goods_id: id
    }
  })
}
