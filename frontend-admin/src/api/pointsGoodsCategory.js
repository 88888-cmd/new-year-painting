import request from '@/utils/request'

export function getList() {
  return request({
    url: '/pointsGoodsCategory/getList',
    method: 'get'
  })
}

export function add(data) {
  return request({
    url: '/pointsGoodsCategory/add',
    method: 'post',
    data
  })
}

export function edit(data) {
  return request({
    url: '/pointsGoodsCategory/edit',
    method: 'post',
    data
  })
}


export function del(id) {
  return request({
    url: '/pointsGoodsCategory/delete',
    method: 'post',
    data: {
      category_id: id
    }
  })
}
