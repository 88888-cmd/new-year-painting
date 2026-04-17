import request from '@/utils/request'

export function getList() {
  return request({
    url: '/goodsCategory/getList',
    method: 'get'
  })
}

export function add(data) {
  return request({
    url: '/goodsCategory/add',
    method: 'post',
    data
  })
}

export function edit(data) {
  return request({
    url: '/goodsCategory/edit',
    method: 'post',
    data
  })
}


export function del(id) {
  return request({
    url: '/goodsCategory/delete',
    method: 'post',
    data: {
      category_id: id
    }
  })
}
