

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reminder/core/theme/app_colors.dart';

import 'package:reminder/feature/auth/presentation/view/login_page.dart';
import 'package:reminder/feature/profile/presentation/widgets/custom_header_widget.dart';
import 'package:reminder/feature/profile/presentation/widgets/custom_menu_widget.dart';
import 'package:reminder/feature/profile/presentation/widgets/language_bottom_sheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        } else if (state is ProfileLoaded) {
          return Column(
            children: [
              ProfileHeader(user: state.user),
              const SizedBox(height: 30),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        ProfileMenuItem(
                          icon: Icons.person_outline_rounded,
                          title: AppLocalizations.of(context)!.accountSettings,
                          onTap: () {},
                        ),
                      
                        ProfileMenuItem(
                          icon: Icons.translate_rounded,
                          title: AppLocalizations.of(context)!.language,
                          onTap: () {
                   LanguageBottomSheet.show(context);
                          },
                        ), 
                        // ProfileMenuItem(
                        //   icon: Icons.notifications_none_rounded,
                        //   title: AppLocalizations.of(context)!.notifications,
                        //   onTap: () {},
                        // ),
                        // ProfileMenuItem(
                        //   icon: Icons.lock_outline_rounded,
                        //   title: AppLocalizations.of(context)!.privacyPolicy,
                        //   onTap: () {},
                        // ),

                        ProfileMenuItem(
                          icon: Icons.logout_rounded,
                          title: AppLocalizations.of(context)!.logout,
                          isLogout: true,
                          onTap: () async {
                            await Supabase.instance.client.auth.signOut();

                            final settings = Hive.box('users_box');
                            await settings.delete('current_user_box');

                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()),
                                (route) => false,
                              );
                            }
                          },
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        } else if (state is ProfileError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message),
                TextButton(
                  onPressed: () => context.read<ProfileCubit>().loadUserData(),
                  child: const Text("Retry"),
                )
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }


}
