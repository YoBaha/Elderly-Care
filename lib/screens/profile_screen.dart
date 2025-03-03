import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  final String token;

  ProfileScreen({required this.token});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfileViewModel(token)..fetchUserData(),
      child: Column(
        children: [
          AppBar(
            title: const Text("Profile"),
          ),
          Expanded(
            child: Consumer<ProfileViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.errorMessage != null) {
                  return Center(child: Text(viewModel.errorMessage!));
                }

                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: viewModel.user?.username ?? '',
                          decoration: const InputDecoration(labelText: 'Username'),
                          onChanged: (value) => viewModel.updateUsername(value),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: viewModel.user?.email ?? '',
                          decoration: const InputDecoration(labelText: 'Email'),
                          onChanged: (value) => viewModel.updateEmail(value),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: viewModel.user?.weight?.toString() ?? '',
                          decoration: const InputDecoration(labelText: 'Weight'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => viewModel.updateWeight(value),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: viewModel.user?.height?.toString() ?? '',
                          decoration: const InputDecoration(labelText: 'Height'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => viewModel.updateHeight(value),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: viewModel.updateUserProfile,
                          child: const Text('Save Changes'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
