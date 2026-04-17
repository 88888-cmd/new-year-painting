import request from '@/utils/request'

export function getList() {
  return request({
    url: '/postsCategory/getList',
    method: 'get'
  })
}

export function add(data) {
  return request({
    url: '/postsCategory/add',
    method: 'post',
    data
  })
}

export function edit(data) {
  return request({
    url: '/postsCategory/edit',
    method: 'post',
    data
  })
}


export function del(id) {
  return request({
    url: '/postsCategory/delete',
    method: 'post',
    data: {
      category_id: id
    }
  })
}
