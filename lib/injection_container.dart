import 'package:get_it/get_it.dart';
import 'package:landing_groom_page/features/contact/data/datasources/firebase_contact_datasource.dart';
import 'package:landing_groom_page/features/contact/data/repositories/contact_repository_impl.dart';
import 'package:landing_groom_page/features/contact/domain/repositories/contact_repository.dart';
import 'package:landing_groom_page/features/contact/domain/usecases/submit_contact.dart';
import 'package:landing_groom_page/features/contact/presentation/cubit/contact_cubit.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  if (sl.isRegistered<ContactCubit>()) return;

  sl
    ..registerLazySingleton<ContactDatasource>(FirebaseContactDatasource.new)
    ..registerLazySingleton<ContactRepository>(
      () => ContactRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => SubmitContact(sl()))
    ..registerFactory(() => ContactCubit(sl()));
}
