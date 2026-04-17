import 'package:app/widgets/button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AddWishPage extends StatefulWidget {
  const AddWishPage({super.key});

  @override
  State<AddWishPage> createState() => _AddWishPageState();
}

class _AddWishPageState extends State<AddWishPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('许愿'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '选择年画',
                style: TextStyle(
                  color: Color(0xFF654941),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),

              GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  // childAspectRatio: 0.75,
                  childAspectRatio: 1.4,
                  crossAxisSpacing: 13,
                  mainAxisSpacing: 13,
                ),
                itemCount: 2,
                itemBuilder:
                    (context, index) => GestureDetector(
                      onTap: () {},
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 0.5,
                              blurRadius: 1.5,
                              offset: Offset(0, 1),
                            ),
                          ],
                          border: index == 0 ? Border.all(width: 2, color: Color(0xFF8d6e63)): null
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                                child: CachedNetworkImage(
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  imageUrl:
                                      'http://www.nianhua.org.cn/data/collections_fine//09_%E3%80%8A%E9%97%A8%E7%A5%9E%E3%80%8B%EF%BC%88%E5%AF%B9%E5%B9%85%EF%BC%89_Door%20Gods/_.jpg',
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Text(
                                    '年画名称',
                                    style: TextStyle(
                                      color: Color(0xFF654941),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ),

              SizedBox(height: 30),
              Text(
                '写下你的愿望',
                style: TextStyle(
                  color: Color(0xFF654941),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),

              TextField(
                maxLines: 5,
                style: const TextStyle(color: Color(0xFF654941), fontSize: 15),
                decoration: InputDecoration(
                  hintText: '分享你与这幅年画的故事、回忆或感受...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF9DA4B0),
                    fontSize: 15,
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    borderSide: BorderSide(
                      width: 1,
                      color: const Color(0xFFd7ccc8),
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    borderSide: BorderSide(
                      width: 1,
                      color: const Color(0xFF8d6e63),
                    ),
                  ),
                  isCollapsed: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 13,
                  ),
                ),
              ),
              SizedBox(height: 40),
              PrimaryButton(
                width: double.infinity,
                title: '许下愿望',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
