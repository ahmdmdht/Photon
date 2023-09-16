import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/features/quiz/cubits/contestCubit.dart';
import 'package:flutterquiz/features/quiz/models/contest.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainner.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

/// Contest Type
const int _Past = 0;
const int _Live = 1;
const int _Upcoming = 2;

class ContestScreen extends StatefulWidget {
  @override
  _ContestScreen createState() => _ContestScreen();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<ContestCubit>(
            create: (_) => ContestCubit(QuizRepository()),
          ),
          BlocProvider<UpdateScoreAndCoinsCubit>(
            create: (_) => UpdateScoreAndCoinsCubit(
              ProfileManagementRepository(),
            ),
          ),
        ],
        child: ContestScreen(),
      ),
    );
  }
}

class _ContestScreen extends State<ContestScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    context
        .read<ContestCubit>()
        .getContest(context.read<UserDetailsCubit>().getUserId());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text(
                AppLocalization.of(context)!.getTranslatedValues("contestLbl")!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
              leading: CustomBackButton(),
              centerTitle: true,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Theme.of(context)
                        .colorScheme
                        .onTertiary
                        .withOpacity(0.08),
                  ),
                  child: TabBar(
                    tabs: [
                      Tab(
                        text: AppLocalization.of(context)!
                            .getTranslatedValues("pastLbl"),
                      ),
                      Tab(
                        text: AppLocalization.of(context)!
                            .getTranslatedValues("liveLbl"),
                      ),
                      Tab(
                        text: AppLocalization.of(context)!
                            .getTranslatedValues("upcomingLbl"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: BlocConsumer<ContestCubit, ContestState>(
              bloc: context.read<ContestCubit>(),
              listener: (context, state) {
                if (state is ContestFailure) {
                  if (state.errorMessage == unauthorizedAccessCode) {
                    UiUtils.showAlreadyLoggedInDialog(context: context);
                  }
                }
              },
              builder: (context, state) {
                if (state is ContestProgress || state is ContestInitial) {
                  return Center(
                    child: CircularProgressContainer(useWhiteLoader: false),
                  );
                }
                if (state is ContestFailure) {
                  print(state.errorMessage);
                  return ErrorContainer(
                    errorMessage:
                    AppLocalization.of(context)!.getTranslatedValues(
                      convertErrorCodeToLanguageKey(state.errorMessage),
                    ),
                    onTapRetry: () {
                      context.read<ContestCubit>().getContest(
                        context.read<UserDetailsCubit>().getUserId(),
                      );
                    },
                    showErrorImage: true,
                  );
                }
                final contestList = (state as ContestSuccess).contestList;
                return TabBarView(
                  children: [
                    past(contestList.past),
                    live(contestList.live),
                    future(contestList.upcoming)
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget past(Contest data) {
    return data.errorMessage.isNotEmpty
        ? contestErrorContainer(data)
        : ListView.builder(
      shrinkWrap: false,
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: data.contestDetails.length,
      itemBuilder: (_, i) => _ContestCard(
        contestDetails: data.contestDetails[i],
        contestType: _Past,
      ),
    );
  }

  Widget live(Contest data) {
    return data.errorMessage.isNotEmpty
        ? contestErrorContainer(data)
        : ListView.builder(
      shrinkWrap: false,
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: data.contestDetails.length,
      itemBuilder: (_, i) => _ContestCard(
        contestDetails: data.contestDetails[i],
        contestType: _Live,
      ),
    );
  }

  Widget future(Contest data) {
    return data.errorMessage.isNotEmpty
        ? contestErrorContainer(data)
        : ListView.builder(
      shrinkWrap: false,
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: data.contestDetails.length,
      itemBuilder: (_, i) => _ContestCard(
        contestDetails: data.contestDetails[i],
        contestType: _Upcoming,
      ),
    );
  }

  ErrorContainer contestErrorContainer(Contest data) {
    return ErrorContainer(
      showBackButton: false,
      errorMessage: AppLocalization.of(context)!.getTranslatedValues(
        convertErrorCodeToLanguageKey(data.errorMessage),
      )!,
      onTapRetry: () => context.read<ContestCubit>().getContest(
        context.read<UserDetailsCubit>().getUserId(),
      ),
      showErrorImage: true,
    );
  }
}

class _ContestCard extends StatefulWidget {
  const _ContestCard({
    Key? key,
    required this.contestDetails,
    required this.contestType,
  }) : super(key: key);

  final ContestDetails contestDetails;
  final int contestType;

  @override
  State<_ContestCard> createState() => _ContestCardState();
}

class _ContestCardState extends State<_ContestCard> {
  void _handleOnTap() {
    if (widget.contestType == _Past) {
      Navigator.of(context).pushNamed(
        Routes.contestLeaderboard,
        arguments: {"contestId": widget.contestDetails.id},
      );
    }
    if (widget.contestType == _Live) {
      if (int.parse(context.read<UserDetailsCubit>().getCoins()!) >=
          int.parse(widget.contestDetails.entry!)) {
        context.read<UpdateScoreAndCoinsCubit>().updateCoins(
          context.read<UserDetailsCubit>().getUserId(),
          int.parse(widget.contestDetails.entry!),
          false,
          AppLocalization.of(context)!
              .getTranslatedValues(playedContestKey) ??
              "-",
        );

        context.read<UserDetailsCubit>().updateCoins(
          addCoin: false,
          coins: int.parse(widget.contestDetails.entry!),
        );
        Navigator.of(context).pushReplacementNamed(
          Routes.quiz,
          arguments: {
            "numberOfPlayer": 1,
            "quizType": QuizTypes.contest,
            "contestId": widget.contestDetails.id,
            "quizName": "Contest"
          },
        );
      } else {
        UiUtils.setSnackbar(
          AppLocalization.of(context)!.getTranslatedValues("noCoinsMsg")!,
          context,
          false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _boldTextStyle = TextStyle(
      color: Theme.of(context).colorScheme.onTertiary,
      fontWeight: FontWeight.bold,
    );
    final _normalTextStyle = TextStyle(
      color: Theme.of(context).colorScheme.onTertiary.withOpacity(0.5),
    );
    final borderDecoration = BoxDecoration(
      border: Border(
        right: BorderSide(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: 0.7,
        ),
      ),
    );
    return Container(
      height: widget.contestDetails.showDescription == false
          ? MediaQuery.of(context).size.height * .44
          : MediaQuery.of(context).size.height * .49,
      margin: EdgeInsets.all(15),
      width: MediaQuery.of(context).size.width * .9,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        boxShadow: [
          UiUtils.buildBoxShadow(
            offset: Offset(5, 5),
            blurRadius: 10.0,
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: GestureDetector(
        onTap: _handleOnTap,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedNetworkImage(
                imageUrl: widget.contestDetails.image.toString(),
                placeholder: (_, i) => Center(
                  child: CircularProgressContainer(useWhiteLoader: false),
                ),
                imageBuilder: (_, img) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(image: img, fit: BoxFit.cover),
                    ),
                    height: 171,
                    width: double.maxFinite,
                  );
                },
                errorWidget: (_, i, e) => Center(
                  child: Icon(
                    Icons.error,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.contestDetails.name.toString(),
                    style: _boldTextStyle,
                  ),
                  widget.contestDetails.description!.toString().length > 50
                      ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .onTertiary
                            .withOpacity(0.3),
                      ),
                    ),
                    alignment: Alignment.center,
                    height: 30,
                    width: 30,
                    padding: EdgeInsets.zero,
                    child: IconButton(
                      iconSize: 30,
                      padding: EdgeInsets.zero,
                      alignment: Alignment.center,
                      onPressed: () {
                        setState(() {
                          widget.contestDetails.showDescription =
                          !widget.contestDetails.showDescription!;
                        });
                      },
                      icon: Icon(
                        widget.contestDetails.showDescription!
                            ? Icons.keyboard_arrow_up_sharp
                            : Icons.keyboard_arrow_down_sharp,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),
                  )
                      : const SizedBox(),
                ],
              ),
              SizedBox(
                width: !widget.contestDetails.showDescription!
                    ? MediaQuery.of(context).size.width * 0.6
                    : MediaQuery.of(context).size.width,
                child: Text(
                  widget.contestDetails.description!,
                  style: TextStyle(
                    color: Theme.of(context).canvasColor.withOpacity(0.5),
                  ),
                  maxLines: !widget.contestDetails.showDescription! ? 1 : 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 10),
              Divider(
                color: Theme.of(context).scaffoldBackgroundColor,
                height: 0,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: borderDecoration,
                        child: Column(
                          children: [
                            Text(
                              AppLocalization.of(context)!
                                  .getTranslatedValues("entryFeesLbl")!,
                              style: _normalTextStyle,
                            ),
                            Text(
                              widget.contestDetails.entry.toString(),
                              style: _boldTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: borderDecoration,
                        child: Column(
                          children: [
                            Text(
                              AppLocalization.of(context)!
                                  .getTranslatedValues("endsOnLbl")!,
                              style: _normalTextStyle,
                            ),
                            Text(
                              widget.contestDetails.endDate.toString(),
                              style: _boldTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            AppLocalization.of(context)!
                                .getTranslatedValues("playersLbl")!,
                            style: _normalTextStyle,
                          ),
                          Text(
                            widget.contestDetails.participants.toString(),
                            style: _boldTextStyle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
