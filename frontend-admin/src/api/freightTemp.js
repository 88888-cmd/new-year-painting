import request from '@/utils/request'

export function getList() {
  return request({
    url: '/freightTemp/getList',
    method: 'get'
  })
}

export function add(data) {
  return request({
    url: '/freightTemp/add',
    method: 'post',
    data
  })
}

export function edit(data) {
  return request({
    url: '/freightTemp/edit',
    method: 'post',
    data
  })
}

export function detail(id) {
  return request({
    url: '/freightTemp/detail',
    method: 'get',
    params: {
      temp_id: id
    }
  })
}


export function del(id) {
  return request({
    url: '/freightTemp/delete',
    method: 'post',
    data: {
      temp_id: id
    }
  })
}
