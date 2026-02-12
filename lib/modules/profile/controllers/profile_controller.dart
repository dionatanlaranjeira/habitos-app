import 'package:image_picker/image_picker.dart';

import '../../../core/core.dart';
import '../../../global_modules/global_modules.dart';
import '../mixins/mixins.dart';

class ProfileController with ProfileVariables {
  ProfileController(this._userRepository, this._userStore);

  final UserRepository _userRepository;
  final UserStore _userStore;
  final _picker = ImagePicker();

  void init() {
    final currentUser = _userStore.user.value;
    if (currentUser != null) {
      nameController.text = currentUser.name;
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final image = await _picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (image != null) {
      avatarFile.value = image;
    }
  }

  Future<void> save() async {
    final user = _userStore.user.value;
    if (user == null) return;

    await FutureHandler<void>(
      asyncState: saveStatus,
      futureFunction: _performSave(user),
    ).call();
  }

  Future<void> _performSave(UserModel user) async {
    String? photoUrl = user.photoUrl;

    // 1. Upload image if changed
    if (avatarFile.value != null) {
      photoUrl = await _userRepository.uploadProfilePicture(
        user.uid,
        avatarFile.value!.path,
      );
    }

    // 2. Update Firestore
    final updatedData = {
      'name': nameController.text.trim(),
      'photoUrl': photoUrl,
    };

    await _userRepository.updateUser(user.uid, updatedData);

    // 3. Update local store
    _userStore.user.value = user.copyWith(
      name: nameController.text.trim(),
      photoUrl: photoUrl,
    );
  }

  void dispose() {
    nameController.dispose();
  }
}

// Extension to help copyWith in UserModel if not available
extension on UserModel {
  UserModel copyWith({String? name, String? photoUrl}) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
    );
  }
}
