import 'package:app/i18n/index.dart';
import 'package:app/pages/updateProfile/controller.dart';
import 'package:app/routes/routes.dart';
import 'package:app/utils/assets_picker.dart';
import 'package:app/utils/constants.dart';
import 'package:app/widgets/button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<UpdateProfileController>(
      init: UpdateProfileController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(LocaleKeys.update_profile.tr),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      AssetsPicker.image(context: context).then((
                        XFile? xfile,
                      ) async {
                        if (xfile != null) {
                          if ((await xfile.length()) >= 5 * 1024 * 1024) {
                            EasyLoading.showToast('最大文件大小为5MB');
                            return;
                          }
                          controller.upload(xfile);
                        }
                      });
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF5F5F5),
                        border: Border.all(color: Color(0xFFd7ccc8), width: 1),
                      ),
                      child: Center(
                        child: controller.avatar == null
                            ? Icon(
                                Icons.person_rounded,
                                size: 40,
                                color: Color(0xFFd7ccc8),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      Constants.mediaBaseUrl +
                                      controller.avatar!.file_url,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    LocaleKeys.click_to_upload_avatar.tr,
                    style: TextStyle(
                      color: Color(0xFF8d6e63),
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25),
              _buildInputField(
                controller: controller.nicknameController,
                label: LocaleKeys.nickname.tr,
                hintText: LocaleKeys.enter_nickname.tr,
              ),
              SizedBox(height: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.birthday.tr,
                    style: TextStyle(
                      color: Color(0xFF654941),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      showDatePicker(
                        context: context,
                        initialDate: controller.selectedDate ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Color(0xFF8d6e63),
                                onPrimary: Colors.white,
                                surface: Colors.white,
                                onSurface: Color(0xFF654941),
                              ),
                              buttonTheme: ButtonThemeData(
                                textTheme: ButtonTextTheme.primary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      ).then((result) {
                        if (result != null) {
                          setState(() {
                            controller.selectedDate = result;
                          });
                        }
                      });
                    },
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          width: 1,
                          color: const Color(0xFFd7ccc8),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              controller.selectedDate != null
                                  ? '${controller.selectedDate!.year}-${controller.selectedDate!.month}-${controller.selectedDate!.day}'
                                  : LocaleKeys.select_date.tr,
                              style: TextStyle(
                                color: controller.selectedDate != null
                                    ? Color(0xFF654941)
                                    : Color(0xFF9DA4B0),
                                fontSize: 15,
                              ),
                            ),
                            Icon(
                              Icons.calendar_today,
                              color: Color(0xFF8d6e63),
                              size: 13,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.gender.tr,
                    style: TextStyle(
                      color: Color(0xFF654941),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        width: 1,
                        color: const Color(0xFFd7ccc8),
                      ),
                    ),
                    child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          elevation: 1,
                          borderRadius: BorderRadius.circular(6),
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          items: [
                            DropdownMenuItem(
                              child: Text(
                                LocaleKeys.gender_male.tr,
                                style: TextStyle(
                                  color: Color(0xFF8d6e63),
                                  fontSize: 15,
                                ),
                              ),
                              value: 0,
                            ),
                            DropdownMenuItem(
                              child: Text(
                                LocaleKeys.gender_female.tr,
                                style: TextStyle(
                                  color: Color(0xFF8d6e63),
                                  fontSize: 15,
                                ),
                              ),
                              value: 1,
                            ),
                          ],
                          value: controller.gender,
                          onChanged: (value) {
                            setState(() {
                              controller.gender = value ?? 0;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              _buildInputField(
                controller: controller.professionController,
                label: LocaleKeys.profession.tr,
                hintText: LocaleKeys.enter_profession.tr,
              ),

              SizedBox(height: 40),
              PrimaryButton(
                width: double.infinity,
                // gbColor: Colors.grey.withOpacity(0.6),
                title: LocaleKeys.confirm.tr,
                onPressed: () {
                  controller.clickSubmit();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF654941),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLength: maxLength,
          maxLines: maxLines,
          style: const TextStyle(color: Color(0xFF654941), fontSize: 15),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF9DA4B0), fontSize: 15),
            fillColor: Colors.white,
            filled: true,
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              borderSide: BorderSide(width: 1, color: Color(0xFFd7ccc8)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              borderSide: BorderSide(width: 1, color: Color(0xFF8d6e63)),
            ),
            isCollapsed: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
            counterText: '',
          ),
        ),
      ],
    );
  }
}
