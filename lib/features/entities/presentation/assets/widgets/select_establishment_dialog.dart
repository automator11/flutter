import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../../config/themes/colors.dart';
import '../../../../main_screen/presentation/cubit/cubits.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../../../core/resources/constants.dart';
import '../../../../../core/utils/debouncer.dart';
import '../../../../user/data/models/models.dart';
import '../../../data/models/models.dart';
import '../cubits/cubits.dart';

class SelectEstablishmentDialog extends StatefulWidget {
  const SelectEstablishmentDialog({super.key});

  @override
  State<SelectEstablishmentDialog> createState() =>
      _SelectEstablishmentDialogState();
}

class _SelectEstablishmentDialogState extends State<SelectEstablishmentDialog> {
  EntityModel? selectedEstablishment;
  UserModel? _user;

  List<EntityModel> assets = [];

  bool _isLoading = false;

  String _search = '';

  @override
  void initState() {
    _user = context.read<AuthCubit>().user;
    context.read<EstablishmentsCubit>().searchEstablishments(_search);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: PointerInterceptor(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 350, maxHeight: 500),
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 50, 16.0, 16.0),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text(
                      'selectEstablishment',
                      style: TextStyle(
                          color: kSecondaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    ).tr(),
                    CustomTextField(
                      label: '',
                      hint: 'search'.tr(),
                      onSave: (value) {},
                      onChange: (value) {
                        Debouncer deb = Debouncer(milliseconds: 500);
                        deb.run(() {
                          _search = value;
                          context
                              .read<EstablishmentsCubit>()
                              .searchEstablishments(value);
                        });
                      },
                    ),
                    SizedBox(
                      height: 300,
                      child: BlocConsumer<EstablishmentsCubit,
                          EstablishmentsState>(
                        listener: (context, state) {
                          if (_isLoading) {
                            _isLoading = false;
                            Navigator.of(context, rootNavigator: true).pop();
                          }
                          if (state is EstablishmentsLoading) {
                            _isLoading = true;
                            MyDialogs.showLoadingDialog(
                                context,
                                'loadingDeleteAsset'
                                    .tr(args: [kEstablishmentTypeKey]));
                          }
                          if (state is EstablishmentsSuccess) {
                            EntityModel? currentEstablishment = context
                                .read<AppStateCubit>()
                                .currentEstablishment;
                            if (state.establishmentId ==
                                currentEstablishment!.id.id) {
                              context
                                  .read<AppStateCubit>()
                                  .currentEstablishment = null;
                            }
                            MyDialogs.showSuccessDialog(
                                context,
                                'deleteAssetSuccess'
                                    .tr(args: [kEstablishmentTypeKey]));
                            context
                                .read<EstablishmentsCubit>()
                                .searchEstablishments(_search);
                          }
                          if (state is EstablishmentsFail) {
                            MyDialogs.showErrorDialog(context, state.message);
                          }
                        },
                        builder: (context, state) {
                          if (state is EstablishmentsNewPage) {
                            assets = state.establishments;
                          }
                          return state is EstablishmentsListLoading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : RefreshIndicator(
                                  onRefresh: () => Future.sync(() {
                                    context
                                        .read<EstablishmentsCubit>()
                                        .searchEstablishments(_search);
                                  }),
                                  child: ListView.builder(
                                    itemCount: assets.length,
                                    itemBuilder: (context, index) {
                                      double? totalArea = assets[index]
                                          .additionalInfo?['totalArea'];
                                      return ListTile(
                                        onTap: () {
                                          setState(() {
                                            selectedEstablishment =
                                                assets[index];
                                          });
                                        },
                                        title: Text(assets[index].label ?? ''),
                                        subtitle: Text(
                                            '${'area'.tr()}: ${totalArea != null ? totalArea.toStringAsFixed(2) : '--'} ha'),
                                        selected: selectedEstablishment ==
                                            assets[index],
                                        selectedColor: kAlternate,
                                        trailing: SizedBox(
                                          width: 120,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              CircleButton(
                                                  onTap: () async {
                                                    var result = await context
                                                        .pushNamed<
                                                                EntityModel?>(
                                                            kMapEditAssetPageRoute,
                                                            extra: assets[index],
                                                            queryParameters: {
                                                          'type':
                                                              kEstablishmentTypeKey
                                                        });
                                                    if (result != null &&
                                                        mounted) {
                                                      context
                                                          .read<
                                                              EstablishmentsCubit>()
                                                          .searchEstablishments(
                                                              _search);
                                                    }
                                                  },
                                                  backgroundColor:
                                                      kPrimaryColor,
                                                  elevation: 0,
                                                  icon: const Padding(
                                                    padding:
                                                        EdgeInsets.all(2.0),
                                                    child: Icon(
                                                      Ionicons.pencil_outline,
                                                      color: Colors.white,
                                                      size: 25,
                                                    ),
                                                  )),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              CircleButton(
                                                  onTap: () async {
                                                    bool result = await MyDialogs
                                                            .showQuestionDialog(
                                                          context: context,
                                                          title: 'delete'.tr(
                                                              args: [
                                                                kEstablishmentTypeKey,
                                                                assets[index]
                                                                        .label ??
                                                                    ''
                                                              ]),
                                                          message:
                                                              'deleteMessage'
                                                                  .tr(args: [
                                                            kEstablishmentTypeKey,
                                                            assets[index]
                                                                    .label ??
                                                                ''
                                                          ]),
                                                        ) ??
                                                        false;
                                                    if (result && mounted) {
                                                      context
                                                          .read<
                                                              EstablishmentsCubit>()
                                                          .deleteEstablishment(
                                                              assets[index]
                                                                  .id
                                                                  .id);
                                                    }
                                                  },
                                                  backgroundColor:
                                                      kSecondaryColor,
                                                  elevation: 0,
                                                  icon: const Padding(
                                                    padding:
                                                        EdgeInsets.all(2.0),
                                                    child: Icon(
                                                      Ionicons.trash_outline,
                                                      color: Colors.white,
                                                      size: 25,
                                                    ),
                                                  ))
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 130,
                          child: CustomElevatedButton(
                            borderRadius: 10,
                            onPressed: selectedEstablishment == null
                                ? null
                                : () {
                                    final user = context.read<AuthCubit>().user;
                                    context
                                        .read<AppStateCubit>()
                                        .updateCurrentEstablishment(
                                            selectedEstablishment!,
                                            user!.id.id);
                                    Navigator.pop(context, true);
                                  },
                            child: const Text('select').tr(),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 120,
                          child: CustomElevatedButton(
                              borderRadius: 10,
                              backgroundColor: kSecondaryColor,
                              child: const Text('add').tr(),
                              onPressed: () async {
                                Navigator.pop(context);
                                context.pushNamed<EntityModel?>(
                                    kMapEditAssetPageRoute,
                                    queryParameters: {
                                      'type': kEstablishmentTypeKey
                                    }).then((value) {
                                  if (value != null) {
                                    context
                                        .read<AppStateCubit>()
                                        .updateCurrentEstablishment(
                                            value, _user!.id.id);
                                  }
                                });
                              }),
                        )
                      ],
                    )
                  ]),
                ),
                Positioned(
                    top: 16,
                    right: 16,
                    child: SizedBox(
                      height: 25,
                      width: 25,
                      child: CircleButton(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Ionicons.close,
                          color: kIconLightColor,
                          size: 18,
                        ),
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
