import 'dart:async';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/auth/authLocalDataSource.dart';
import 'package:flutterquiz/features/auth/authRepository.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';
import 'package:flutterquiz/features/auth/cubits/referAndEarnCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateUserDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/uploadProfileCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/models/userProfile.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:flutterquiz/utils/user_utils.dart';
import 'package:flutterquiz/utils/validators.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class CreateOrEditProfileScreen extends StatefulWidget {
  final bool isNewUser;

  const CreateOrEditProfileScreen({
    super.key,
    required this.isNewUser,
  });

  @override
  State<CreateOrEditProfileScreen> createState() =>
      _SelectProfilePictureScreen();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<UploadProfileCubit>(
            create: (_) => UploadProfileCubit(ProfileManagementRepository()),
          ),
          BlocProvider<ReferAndEarnCubit>(
            create: (_) => ReferAndEarnCubit(AuthRepository()),
          ),
          BlocProvider<UpdateUserDetailCubit>(
            create: (_) => UpdateUserDetailCubit(ProfileManagementRepository()),
          ),
        ],
        child: CreateOrEditProfileScreen(
          isNewUser: routeSettings.arguments as bool,
        ),
      ),
    );
  }
}

class _SelectProfilePictureScreen extends State<CreateOrEditProfileScreen> {
  File? selectedImage;
  String? selectedAvatar;

  final _formKey = GlobalKey<FormState>();
  TextEditingController? nameController;
  TextEditingController? emailController;
  TextEditingController? phoneController;
  TextEditingController inviteTextEditingController = TextEditingController();
  bool iHaveInviteCode = false;

  bool isPhoneTextFieldEnabled = false;
  bool isEmailTextFieldEnabled = false;

  @override
  initState() {
    super.initState();
    final authType = AuthLocalDataSource.getAuthType();
    if (!widget.isNewUser) {
      if (authType == "mobile") {
        isEmailTextFieldEnabled = true;
        isPhoneTextFieldEnabled = false;
      } else if (authType == "gmail" ||
          authType == "email" ||
          authType == "apple") {
        isEmailTextFieldEnabled = false;
        isPhoneTextFieldEnabled = true;
      }
    }
  }

  //convert image to file
  Future<void> uploadProfileImage(String imageName) async {
    final byteData =
        await rootBundle.load(UiUtils.getprofileImagePath(imageName));
    final file = File('${(await getTemporaryDirectory()).path}/temp.png');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    final userId = context.read<UserDetailsCubit>().userId();
    await context.read<UploadProfileCubit>().uploadProfilePicture(file, userId);
  }

  Widget _buildCurrentProfilePictureContainer(
      {required String image, required bool isFile, required isAsset}) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;

    if (image.isEmpty) {
      if (widget.isNewUser) {
        return DottedBorder(
          strokeWidth: 3,
          padding: EdgeInsets.zero,
          borderType: BorderType.RRect,
          dashPattern: const [8, 3],
          color: colorScheme.onTertiary.withOpacity(.5),
          radius: const Radius.circular(8.0),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: colorScheme.background,
              minimumSize: Size(width * .9, 48),
            ),
            onPressed: chooseImageFromCameraOrGallery,
            child: Text(
              AppLocalization.of(context)!.getTranslatedValues('choosePhoto')!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeights.medium,
                color: colorScheme.onTertiary,
              ),
            ),
          ),
        );
      }
      return GestureDetector(
        onTap: chooseImageFromCameraOrGallery,
        child: Container(
          width: width * (0.3),
          height: width * (0.3),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.add_a_photo,
              color: colorScheme.background,
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: width * (0.3),
      height: width * (0.3),
      child: LayoutBuilder(
        builder: (_, constraints) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: width * (0.3),
                  height: width * (0.3),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.background),
                    shape: BoxShape.circle,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(width * .15),
                    child: isFile
                        ? Image.file(File(image))
                        : isAsset
                            ? Image.asset(UiUtils.getprofileImagePath(image))
                            : UserUtils.getUserProfileWidget(
                                profileUrl: image,
                                isSimpleNetworkImage: true,
                              ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: chooseImageFromCameraOrGallery,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.background,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(5),
                    height: constraints.maxWidth * (0.25),
                    width: constraints.maxWidth * (0.25),
                    child: Icon(
                      Icons.add_a_photo,
                      color: Theme.of(context).primaryColor,
                      size: 15.0,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // get image File camera
  void _getFromCamera(BuildContext context) async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );

    final croppedFile = await _croppedImage(pickedFile!.path);

    setState(() {
      selectedImage = File(croppedFile!.path);
      selectedAvatar = null;
    });
  }

  //get image file from library
  void _getFromGallery(BuildContext context) async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );

    final croppedFile = await _croppedImage(pickedFile!.path);

    setState(() {
      selectedImage = File(croppedFile!.path);
      selectedAvatar = null;
    });
  }

  Future<CroppedFile?> _croppedImage(String pickedFilePath) async {
    return await ImageCropper().cropImage(
      sourcePath: pickedFilePath,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      cropStyle: CropStyle.circle,
      compressFormat: ImageCompressFormat.png,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Theme.of(context).primaryColor,
          toolbarWidgetColor: Theme.of(context).colorScheme.background,
          initAspectRatio: CropAspectRatioPreset.square,
          activeControlsWidgetColor: Theme.of(context).primaryColor,
        ),
        IOSUiSettings(title: 'Cropper'),
      ],
    );
  }

  void chooseImageFromCameraOrGallery() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: UiUtils.bottomSheetTopRadius,
      ),
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: UiUtils.bottomSheetTopRadius,
        ),
        height: MediaQuery.of(context).size.height * .21,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * .02,
          left: MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
          right: MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Profile Photo",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onTertiary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _getFromCamera(context);
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .onTertiary
                                .withOpacity(0.2),
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Theme.of(context).primaryColor,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLocalization.of(context)!
                          .getTranslatedValues("cameraLbl")!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _getFromGallery(context);
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .onTertiary
                                .withOpacity(0.2),
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          Icons.photo_library_rounded,
                          color: Theme.of(context).primaryColor,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLocalization.of(context)!
                          .getTranslatedValues("photoLibraryLbl")!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectAvatarText() {
    return Center(
      child: Text(
        "${toBeginningOfSentenceCase(AppLocalization.of(context)!.getTranslatedValues("orLbl")!)} ${AppLocalization.of(context)!.getTranslatedValues("selectProfilePhotoLbl")!}",
        style: TextStyle(
          color: Theme.of(context).colorScheme.onTertiary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDefaultAvtarImage(int index, String imageName) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAvatar = imageName;
          selectedImage = null;
        });
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          double profileRadiusPercentage = constraints.maxHeight <
                  UiUtils.profileHeightBreakPointResultScreen
              ? 0.175
              : 0.2;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 7),
            height: MediaQuery.of(context).size.height * .18,
            width: MediaQuery.of(context).size.width * .18,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: CircleAvatar(
              radius:
                  constraints.maxHeight * (profileRadiusPercentage - 0.0535),
              backgroundImage: AssetImage(
                UiUtils.getprofileImagePath(imageName),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDefaultAvtarImages() {
    final defaultProfileImages =
        (context.read<SystemConfigCubit>().state as SystemConfigFetchSuccess)
            .defaultProfileImages;

    if (widget.isNewUser) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * (0.23),
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: defaultProfileImages.length,
          itemBuilder: (_, i) => _buildDefaultAvtarImage(
            i,
            defaultProfileImages[i],
          ),
        ),
      );
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * (0.13),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: defaultProfileImages.length,
        itemBuilder: (_, i) => _buildDefaultAvtarImage(
          i,
          defaultProfileImages[i],
        ),
      ),
    );
  }

  //continue button will listen to two cubit one is for changing name and other is
  //for uploading profile picture
  Widget _buildContinueButton(UserProfile userProfile) {
    return BlocConsumer<UploadProfileCubit, UploadProfileState>(
      bloc: context.read<UploadProfileCubit>(),
      listener: (context, state) {
        if (state is UploadProfileFailure) {
          UiUtils.setSnackbar(
            AppLocalization.of(context)!.getTranslatedValues(
              convertErrorCodeToLanguageKey(state.errorMessage),
            )!,
            context,
            false,
          );
        } else if (state is UploadProfileSuccess) {
          context.read<UserDetailsCubit>().updateUserProfileUrl(state.imageUrl);
        }
      },
      builder: (context, state) {
        /// for updating name,email, number
        return BlocConsumer<ReferAndEarnCubit, ReferAndEarnState>(
          listener: (_, referState) {
            if (referState is ReferAndEarnFailure) {
              UiUtils.setSnackbar(
                AppLocalization.of(context)!.getTranslatedValues(
                    convertErrorCodeToLanguageKey(referState.errorMessage))!,
                context,
                false,
              );
            }
            if (referState is ReferAndEarnSuccess) {
              context.read<UserDetailsCubit>().updateUserProfile(
                    name: referState.userProfile.name,
                    email: referState.userProfile.email,
                    mobile: referState.userProfile.mobileNumber,
                    coins: referState.userProfile.coins!,
                  );

              context.read<UpdateUserDetailCubit>().updateProfile(
                    userId: referState.userProfile.userId!,
                    email: emailController!.text,
                    name: nameController!.text,
                    mobile: phoneController!.text,
                  );

              Navigator.of(context).pushReplacementNamed(
                Routes.home,
                arguments: false,
              );
            }
          },
          builder: (context, referState) {
            return BlocConsumer<UpdateUserDetailCubit, UpdateUserDetailState>(
              listener: (_, state) {
                if (state is UpdateUserDetailSuccess ||
                    state is UpdateUserDetailFailure) {
                  Navigator.pop(context);
                }
              },
              builder: (updateContext, updateState) {
                print("state print ${state.toString()}");
                final textButtonKey =
                    updateState is UpdateUserDetailInProgress ||
                            context.read<UploadProfileCubit>().state
                                is UploadProfileInProgress
                        ? "uploadingBtn"
                        : "continueLbl";
                return TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                  ),
                  onPressed: () async {
                    //if upload profile is in progress
                    if (state is UploadProfileInProgress) {
                      return;
                    }

                    if (context.read<UpdateUserDetailCubit>().state
                        is UpdateUserDetailInProgress) {
                      return;
                    }

                    //if update name is in progress
                    if (referState is ReferAndEarnProgress) {
                      return;
                    }

                    //if profile is empty
                    if (selectedAvatar == null &&
                        selectedImage == null &&
                        userProfile.profileUrl!.isEmpty) {
                      UiUtils.setSnackbar(
                          AppLocalization.of(context)!
                              .getTranslatedValues("selectProfileLbl")!,
                          context,
                          false);
                      return;
                    }
                    //if use has not enter the name then so enter name snack bar
                    if (nameController!.text.isEmpty) {
                      UiUtils.setSnackbar(
                          AppLocalization.of(context)!
                              .getTranslatedValues("enterValidNameMsg")!,
                          context,
                          false);
                      return;
                    }

                    // Validate Email.
                    if (isEmailTextFieldEnabled) {
                      if (!_formKey.currentState!.validate()) return;
                    }

                    if (selectedAvatar != null) {
                      await uploadProfileImage(selectedAvatar ?? "");
                    } else if (selectedImage != null) {
                      final userId = context.read<UserDetailsCubit>().userId();
                      await context
                          .read<UploadProfileCubit>()
                          .uploadProfilePicture(selectedImage, userId);
                    }

                    if (widget.isNewUser) {
                      context.read<ReferAndEarnCubit>().getReward(
                            name: nameController!.text.trim(),
                            userProfile: userProfile,
                            friendReferralCode: iHaveInviteCode
                                ? inviteTextEditingController.text.trim()
                                : "",
                            authType:
                                context.read<AuthCubit>().getAuthProvider(),
                          );

                      /// ----
                      if (emailController!.text.isNotEmpty ||
                          phoneController!.text.isNotEmpty) {
                        context.read<UserDetailsCubit>().updateUserProfile(
                              email: emailController!.text.trim(),
                              name: nameController!.text.trim(),
                              mobile: phoneController!.text.trim(),
                            );

                        context.read<UpdateUserDetailCubit>().updateProfile(
                              userId: userProfile.userId!,
                              email: emailController!.text,
                              name: nameController!.text,
                              mobile: phoneController!.text,
                            );
                      }

                      Navigator.of(context).pushReplacementNamed(
                        Routes.home,
                        arguments: false,
                      );
                    } else {
                      context.read<UserDetailsCubit>().updateUserProfile(
                            email: emailController!.text.trim(),
                            name: nameController!.text.trim(),
                            mobile: phoneController!.text.trim(),
                          );

                      context.read<UpdateUserDetailCubit>().updateProfile(
                            userId: userProfile.userId!,
                            email: emailController!.text,
                            name: nameController!.text,
                            mobile: phoneController!.text,
                          );
                    }
                  },
                  child: Text(
                    AppLocalization.of(context)!
                        .getTranslatedValues(textButtonKey)!,
                    style: Theme.of(context).textTheme.headlineSmall!.merge(
                          TextStyle(
                            color: Theme.of(context).colorScheme.background,
                          ),
                        ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildNameTextFieldContainer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.isNewUser) ...[
          Text(
            AppLocalization.of(context)!.getTranslatedValues("profileName")!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onTertiary,
            ),
          ),
          const SizedBox(height: 10),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Theme.of(context).colorScheme.background,
          ),
          width: MediaQuery.of(context).size.width,
          height: 50,
          child: TextFormField(
            validator: (_) => null,
            controller: nameController,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            decoration: InputDecoration(
              hintText: AppLocalization.of(context)!
                  .getTranslatedValues("enterNameLbl")!,
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onTertiary.withOpacity(.4),
              ),
              contentPadding: const EdgeInsets.only(left: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailTextFieldContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalization.of(context)!.getTranslatedValues("emailAddress")!,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onTertiary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: isEmailTextFieldEnabled
                ? Theme.of(context).colorScheme.background
                : Theme.of(context).colorScheme.onTertiary.withOpacity(0.2),
          ),
          width: MediaQuery.of(context).size.width,
          height: 50,
          child: Form(
            key: _formKey,
            child: TextFormField(
              readOnly: !isEmailTextFieldEnabled,
              enabled: isEmailTextFieldEnabled,
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (val) {
                return Validators.validateEmail(
                  val!,
                  AppLocalization.of(context)!
                      .getTranslatedValues('emailRequiredMsg')!,
                  AppLocalization.of(context)!
                      .getTranslatedValues('enterValidEmailMsg')!,
                );
              },
              style: TextStyle(
                color: Theme.of(context).colorScheme.onTertiary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              decoration: InputDecoration(
                hintText: AppLocalization.of(context)!
                    .getTranslatedValues("enterEmailLbl"),
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onTertiary.withOpacity(.4),
                ),
                contentPadding: const EdgeInsets.only(left: 10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneTextFieldContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalization.of(context)!.getTranslatedValues("phoneNumber")!,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onTertiary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: isPhoneTextFieldEnabled
                ? Theme.of(context).colorScheme.background
                : Theme.of(context).colorScheme.onTertiary.withOpacity(0.2),
          ),
          width: MediaQuery.of(context).size.width,
          height: 50,
          child: TextFormField(
            validator: (_) => null,
            readOnly: !isPhoneTextFieldEnabled,
            enabled: isPhoneTextFieldEnabled,
            controller: phoneController,
            inputFormatters: [
              LengthLimitingTextInputFormatter(maxPhoneNumberLength),
              FilteringTextInputFormatter.digitsOnly,
            ],
            keyboardType: TextInputType.phone,
            style: TextStyle(
              color: isPhoneTextFieldEnabled
                  ? Theme.of(context).colorScheme.onTertiary
                  : Theme.of(context).colorScheme.onTertiary.withOpacity(0.4),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            decoration: InputDecoration(
              hintText: "-",
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onTertiary.withOpacity(.4),
              ),
              contentPadding: const EdgeInsets.only(left: 10),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildNameAndReferCodeContainer() {
    final colorScheme = Theme.of(context).colorScheme;

    return [
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: colorScheme.background,
        ),
        padding: const EdgeInsets.all(15),
        margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalization.of(context)!
                      .getTranslatedValues(iHaveInviteCodeKey)!,
                  style: TextStyle(
                    fontWeight: FontWeights.medium,
                    fontSize: 18,
                    color: colorScheme.onTertiary,
                  ),
                ),
                Transform.scale(
                  scale: 0.8,
                  child: CupertinoSwitch(
                    thumbColor: iHaveInviteCode
                        ? Theme.of(context).primaryColor
                        : const Color(0xFF5c5c5c),
                    activeColor: Theme.of(context).scaffoldBackgroundColor,
                    trackColor: Theme.of(context).scaffoldBackgroundColor,
                    value: iHaveInviteCode,
                    onChanged: (v) => setState(() => iHaveInviteCode = v),
                  ),
                )
              ],
            ),
            if (iHaveInviteCode) ...[
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: colorScheme.onTertiary.withOpacity(0.1),
                ),
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  validator: (_) => null,
                  controller: inviteTextEditingController,
                  style: TextStyle(
                    color: colorScheme.onTertiary,
                    fontSize: 18,
                    fontWeight: FontWeights.medium,
                  ),
                  decoration: InputDecoration(
                    hintText: AppLocalization.of(context)!
                        .getTranslatedValues(enterReferralCodeLbl)!,
                    hintStyle: TextStyle(
                      color: colorScheme.onTertiary.withOpacity(.3),
                      fontSize: 18,
                      fontWeight: FontWeights.medium,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              )
            ],
          ],
        ),
      ),
      SizedBox(
        height: MediaQuery.of(context).size.height *
            (iHaveInviteCode ? 0.020 : 0.115),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(!widget.isNewUser),
      child: Scaffold(
        appBar: QAppBar(
          automaticallyImplyLeading: !widget.isNewUser,
          roundedAppBar: !widget.isNewUser,
          title: !widget.isNewUser
              ? Text(
                  AppLocalization.of(context)!
                      .getTranslatedValues("editProfile")!,
                )
              : const SizedBox(),
        ),
        body: Stack(
          children: [
            BlocConsumer<UserDetailsCubit, UserDetailsState>(
              listener: (context, state) {
                //when user register first time then set this listener
                if (state is UserDetailsFetchSuccess && widget.isNewUser) {
                  UiUtils.fetchBookmarkAndBadges(
                    context: context,
                    userId: state.userProfile.userId!,
                  );
                }
              },
              bloc: context.read<UserDetailsCubit>(),
              builder: (context, state) {
                if (state is UserDetailsFetchInProgress ||
                    state is UserDetailsInitial) {
                  return const Center(child: CircularProgressContainer());
                }
                if (state is UserDetailsFetchFailure) {
                  return ErrorContainer(
                    showBackButton: true,
                    errorMessage:
                        AppLocalization.of(context)!.getTranslatedValues(
                      convertErrorCodeToLanguageKey(state.errorMessage),
                    ),
                    onTapRetry: () {
                      context.read<UserDetailsCubit>().fetchUserDetails();
                    },
                    showErrorImage: true,
                  );
                }

                UserProfile userProfile =
                    (state as UserDetailsFetchSuccess).userProfile;

                nameController ??=
                    TextEditingController(text: userProfile.name);
                emailController ??=
                    TextEditingController(text: userProfile.email);
                phoneController ??=
                    TextEditingController(text: userProfile.mobileNumber);

                final size = MediaQuery.of(context).size;

                // TODO: too many conditionals, separate isNewUser logic to one place.
                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: size.height * .025),
                      Center(
                        child: _buildCurrentProfilePictureContainer(
                          image: selectedAvatar != null
                              ? selectedAvatar!
                              : selectedImage != null
                                  ? selectedImage!.path
                                  : userProfile.profileUrl ?? "",
                          isFile: selectedImage != null,
                          isAsset: selectedAvatar != null,
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      _buildSelectAvatarText(),
                      SizedBox(height: size.height * .025),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * UiUtils.hzMarginPct,
                        ),
                        child: _buildDefaultAvtarImages(),
                      ),
                      widget.isNewUser
                          ? const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.0),
                              child: Divider(color: Color(0xFF707070)),
                            )
                          : const Divider(),
                      SizedBox(height: size.height * .02),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * UiUtils.hzMarginPct,
                        ),
                        child: _buildNameTextFieldContainer(),
                      ),
                      SizedBox(height: size.height * .03),
                      if (!widget.isNewUser) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * UiUtils.hzMarginPct,
                          ),
                          child: _buildEmailTextFieldContainer(),
                        ),
                        SizedBox(height: size.height * .03),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * UiUtils.hzMarginPct,
                          ),
                          child: _buildPhoneTextFieldContainer(),
                        ),
                        SizedBox(height: size.height * .03),
                      ] else ...[
                        ..._buildNameAndReferCodeContainer(),
                      ],
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * UiUtils.hzMarginPct,
                        ),
                        child: _buildContinueButton(userProfile),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
