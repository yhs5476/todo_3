// 필요한 패키지 및 모듈 가져오기
import 'package:date_picker_timeline/date_picker_timeline.dart'; // 달력 날짜 선택을 위한 패키지
import 'package:firebase_auth/firebase_auth.dart'; // Firebase 사용자 인증
import 'package:flutter/material.dart'; // 기본 Material 디자인
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart'; // 애니메이션 효과
import 'package:flutter_svg/flutter_svg.dart'; // SVG 이미지 표시
import 'package:get/get.dart'; // GetX 상태 관리 패키지
import 'package:google_fonts/google_fonts.dart'; // 구글 폰트
import 'package:intl/intl.dart'; // 날짜 및 시간 포맷팅
import 'package:todo/services/auth_service.dart'; // 사용자 인증 서비스
import 'package:todo/services/theme_services.dart'; // 테마 관리 서비스
import 'package:todo/ui/pages/add_speech_to_text.dart'; // 음성인식 페이지
import 'package:todo/ui/pages/login_page.dart'; // 로그인 페이지
import 'package:todo/ui/size_config.dart'; // 사이즈 설정
import 'package:todo/ui/theme.dart'; // 앱 테마 설정
import 'package:todo/ui/pages/add_task_page.dart'; // 할일 추가 페이지
import 'package:todo/ui/widgets/button.dart'; // 커스텀 버튼 위젯
import 'package:todo/ui/widgets/task_tile.dart';
import 'package:todo/ui/pages/scripts_page.dart'; // 스크립트 페이지
import '../../controllers/task_controller.dart'; // 할일 관리 컨트롤러
import '../../models/task.dart'; // 할일 모델 정의
import '../widgets/task_bottom_sheet.dart'; // 할 일 관리 바텀 시트 위젯

// 홈 페이지 - 할일 관리의 메인 화면 위젯
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState(); // 상태 관리 클래스 생성
}

// 홈화면의 상태를 관리하는 클래스
class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // 할일 목록 가져오기
    _taskController.getTasks();

    // 사용자 로그인 상태 확인
    _checkUserLogin();
  }

  // 사용자 로그인 상태 확인 메소드
  Future<void> _checkUserLogin() async {
    // Firebase Auth 상태가 정확히 반영될 수 있도록 짧은 딜레이 추가
    await Future.delayed(const Duration(milliseconds: 500));

    // 로그인되지 않았다면 로그인 화면으로 이동
    if (FirebaseAuth.instance.currentUser == null) {
      Get.offAll(() => const LoginPage(),
          transition: Transition.fadeIn); // 로그인 페이지로 강제 이동 (뒤로가기 기록 삭제)
    } else {
      // 로그인되어 있는 경우 사용자 정보 출력 (디버깅 용도)
      print("사용자 로그인됨: ${FirebaseAuth.instance.currentUser?.displayName}");
    }
  }

  // 현재 선택된 날짜 (기본값은 오늘)
  DateTime _selectedDate = DateTime.now();

  // 할일 관리를 위한 컨트롤러 초기화 및 의존성 주입
  final TaskController _taskController = Get.put(TaskController());

  @override
  Widget build(BuildContext context) {
    // 화면 크기 관리 초기화 (반응형 디자인을 위함)
    SizeConfig().init(context);

    return Scaffold(
      // 배경색 설정 - 현재 테마에 따라 다른 배경색 적용
      // ignore: deprecated_member_use
      backgroundColor: context.theme.scaffoldBackgroundColor,

      // 상단 앱바 생성
      appBar: _customAppBar(),

      // 본문 내용 구성
      body: Column(
        children: [
          _addTaskBar(), // 할일 추가 버튼과 날짜 표시 부분
          _addDateBar(), // 달력 날짜 선택기 부분
          const SizedBox(
            height: 6,
          ),
          _showTasks(), // 할일 목록 표시 부분
        ],
      ),

      // 음성 인식으로 할일 추가하는 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 음성인식 페이지로 이동하고, 결과를 AddTaskPage로 전달
          final dynamic speechResult = await Get.to(() => const AddSpeechToTextPage());
          String? recognizedContent;
          if (speechResult != null && speechResult is Map<String, String>) {
            recognizedContent = speechResult['content'];
          }
          // AddTaskPage로 이동하면서 인식된 텍스트 전달 (AddTaskPage 수정 필요)
          await Get.to(() => AddTaskPage(initialTaskContent: recognizedContent));
          _taskController.getTasks(); // 할일 목록 새로고침
        },
        backgroundColor: primaryClr,
        foregroundColor: Colors.white, // 아이콘 색상을 흰색으로 설정
      child: const Icon(Icons.mic), // 마이크 아이콘으로 변경
      ),

      // 플로팅 버튼 위치 (왼쪽 아래쪽 설정)
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  // 커스텀 앱바 구성 메소드
  AppBar _customAppBar() {
    return AppBar(
      // 배경색 설정 - 현재 테마에 따라 표시
      // ignore: deprecated_member_use
      backgroundColor: context.theme.scaffoldBackgroundColor,

      // 그림자 제거 (평면 앱바)
      elevation: 0,
      // title: Text('홈', style: headingStyle), // 필요시 제목 추가
      // 좌측 버튼 - 테마 변경 버튼 구현
      leading: GestureDetector(
        onTap: () {
          // 테마 변경 (라이트/다크 모드 전환)
          ThemeServices().switchTheme();

          //notifyHelper.scheduledNotification();
        },
        // 현재 테마에 따라 다른 아이콘 표시
        child: Icon(
          // 다크 모드일 때 해 아이콘, 라이트 모드일 때 달 아이콘
          Get.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round,
          size: 20,
          // 테마에 따라 아이콘 색상 변경
          color: Get.isDarkMode ? Colors.white : Colors.black,
        ),
      ),

      // 우측 기능 버튼들
      actions: [
        IconButton(
          icon: Icon(Icons.description_outlined, color: Get.isDarkMode ? Colors.white : darkGreyClr, size: 28),
          onPressed: () {
            Get.to(() => ScriptsPage());
          },
        ),
        const SizedBox(width: 10),
        // 사용자 프로필 섹션 (로그아웃 메뉴 포함)
        _buildProfileSection(),
        const SizedBox(width: 20),
      ],
    );
  }

  // 사용자 프로필 및 계정 관리 섹션 구성 메소드
  Widget _buildProfileSection() {
    // 현재 Firebase에 로그인된 사용자 정보 가져오기
    User? user = FirebaseAuth.instance.currentUser;

    // 팝업 메뉴 버튼 구성
    return PopupMenuButton<String>(
      // 사용자 프로필 이미지 표시
      icon: CircleAvatar(
        // 구글 프로필 이미지가 있으면 해당 이미지를 사용, 없으면 기본 이미지 사용
        backgroundImage: user?.photoURL != null
            ? NetworkImage(user!.photoURL!)
            : const AssetImage("images/person.jpeg") as ImageProvider,
        radius: 18,
      ),
      // 메뉴 아이템 선택 시 작업 처리
      onSelected: (value) {
        if (value == 'logout') {
          // 로그아웃 기능 실행
          _handleSignOut();
        }
      },
      // 팝업 메뉴 아이템 구성
      itemBuilder: (BuildContext context) => [
        // 프로필 표시 메뉴
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              const Icon(Icons.person, color: primaryClr),
              const SizedBox(width: 10),
              // 사용자 이름 표시 (없을 경우 기본값 설정)
              Text(user?.displayName ?? '사용자'),
            ],
          ),
        ),
        // 로그아웃 메뉴
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 10),
              Text('로그아웃'),
            ],
          ),
        ),
      ],
    );
  }

  // 로그아웃 처리 메소드
  void _handleSignOut() async {
    // AuthService를 통한 로그아웃 처리
    await Get.find<AuthService>().signOut();

    // 로그인 화면으로 강제 이동 (뒤로가기 기록 삭제)
    Get.offAll(() => const LoginPage());

    // 로그아웃 성공 메시지 표시
    Get.snackbar(
      "로그아웃 성공",
      "로그아웃되었습니다.",
      snackPosition: SnackPosition.BOTTOM, // 하단에 표시
      backgroundColor: Colors.green, // 배경색은 초록색
      colorText: Colors.white, // 텍스트 색상은 흰색
    );
  }

  // 상단 작업 표시줄 생성 메소드 - 날짜 표시와 할 일 추가 버튼을 포함
  _addTaskBar() {
    return Container(
      // 여백 설정 - 좌측, 우측, 상단에 여백 적용
      margin: const EdgeInsets.only(left: 20, right: 10, top: 10),
      child: Row(
        // 자식 요소들을 양 끝으로 정렬 (날짜 정보와 버튼 사이 공간 최대화)
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 왼쪽 부분 - 날짜 정보 표시 영역
          Column(
            // 텍스트를 왼쪽 정렬
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 현재 날짜를 년, 월, 일 형식으로 표시 (예: June 5, 2025)
              Text(
                DateFormat.yMMMMd().format(DateTime.now()),
                style: subHeadingStyle,
              ),
              // '오늘' 텍스트 표시
              Text(
                '오늘',
                style: subHeadingStyle,
              ),
            ],
          ),
          // 오른쪽 부분 - 할 일 추가 버튼
          MyButton(
              label: '+ 할 일 추가',
              onTap: () async {
                // 할 일 추가 페이지로 이동
                await Get.to(() => const AddTaskPage());
                _taskController.getTasks();
              }),
        ],
      ),
    );
  }

  // 날짜 선택 바 생성 메소드 - 수평 스크롤 가능한 날짜 선택기 표시
  _addDateBar() {
    return Container(
      // 여백 설정 - 좌측, 우측, 상단에 여백 적용
      margin: const EdgeInsets.only(left: 20, right: 10, top: 10),
      child: DatePicker(
        // 기준 날짜를 오늘로 설정 (달력의 시작점)
        DateTime.now(),
        // 각 날짜 항목의 너비와 높이 설정
        width: 80,
        height: 100,
        // 초기 선택 날짜를 _selectedDate 변수 값으로 설정
        initialSelectedDate: _selectedDate,
        // 선택된 날짜의 텍스트 색상을 흰색으로 설정
        selectedTextColor: Colors.white,
        // 선택된 날짜의 배경색을 primaryClr로 설정
        selectionColor: primaryClr,
        // 날짜(숫자) 텍스트 스타일 설정
        dateTextStyle: GoogleFonts.lato(
            textStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        )),
        // 요일 텍스트 스타일 설정
        dayTextStyle: GoogleFonts.lato(
            textStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        )),
        // 월 텍스트 스타일 설정
        monthTextStyle: GoogleFonts.lato(
            textStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        )),
        // 날짜가 변경될 때 호출되는 콜백 함수
        onDateChange: (newDate) {
          // 상태 업데이트 - 선택된 날짜 변경
          setState(() {
            _selectedDate = newDate;
          });
          
          // 선택한 날짜의 할일만 필터링하여 표시
          _taskController.getTasksByDate(newDate);
        },
      ),
    );
  }

  // 화면 새로고침 메소드 - 당겨서 새로고침 기능에 사용됨
  Future<void> _onRefresh() async {
    // 할 일 목록을 서버나 로컬 저장소에서 다시 불러옴
    _taskController.getTasks();
  }

  // 할 일 목록 표시 메소드 - 선택된 날짜에 해당하는 할 일 목록을 보여줌
  _showTasks() {
    return Expanded(
      // Obx로 감싸서 _taskController의 상태 변화를 관찰하고 자동으로 UI 업데이트
      child: Obx(() {
        // 할 일 목록이 비어있는 경우 '할 일 없음' 메시지 표시
        if (_taskController.taskList.isEmpty) {
          return _noTaskMsg();
        } else {
          // 할 일 목록이 있는 경우 목록 표시
          return RefreshIndicator(
            // 당겨서 새로고침 기능 설정
            onRefresh: _onRefresh,
            child: ListView.builder(
              // 화면 방향에 따라 스크롤 방향 설정 (가로 또는 세로)
              scrollDirection: SizeConfig.orientation == Orientation.landscape
                  ? Axis.horizontal // 가로 모드일 때 가로 스크롤
                  : Axis.vertical, // 세로 모드일 때 세로 스크롤
              itemBuilder: (BuildContext context, int index) {
                // 현재 인덱스의 할 일 항목 가져오기
                var task = _taskController.taskList[index];

                // 표시할 할 일 필터링 - 다음 조건 중 하나라도 만족하면 표시
                // 1. 매일 반복되는 할 일
                // 2. 선택된 날짜와 할 일의 날짜가 일치하는 경우
                // 3. 주간 반복이고 선택된 날짜가 할 일 생성 날짜로부터 7의 배수 일수가 지난 경우
                // 4. 월간 반복이고 선택된 날짜의 일(day)이 할 일 생성 날짜의 일(day)과 일치하는 경우
                if (task.repeat == 'Daily' ||
                    task.date == DateFormat.yMd().format(_selectedDate) ||
                    (task.repeat == 'Weekly' &&
                        _selectedDate
                                    .difference(
                                        DateFormat.yMd().parse(task.date!))
                                    .inDays %
                                7 ==
                            0) ||
                    (task.repeat == 'Monthly' &&
                        DateFormat.yMd().parse(task.date!).day ==
                            _selectedDate.day)) {
                  try {
                    // 주석 처리된 시간 파싱 코드
                    /*   var hour = task.startTime.toString().split(':')[0];
                    var minutes = task.startTime.toString().split(':')[1]; */

                    // 할 일의 시작 시간 파싱 관련 코드는 알림 기능 제거로 인해 삭제됨
                  } catch (e) {
                    // 시간 파싱 오류 발생 시 콘솔에 오류 출력
                    print('Error parsing time: $e');
                  }
                } else {
                  // 필터링 조건에 맞지 않는 경우 빈 컨테이너 반환 (화면에 표시 안 함)
                  Container();
                }
                // 애니메이션 효과가 적용된 할 일 항목 반환
                return AnimationConfiguration.staggeredList(
                  position: index, // 애니메이션 순서 결정을 위한 인덱스
                  duration: const Duration(milliseconds: 1375), // 애니메이션 지속 시간
                  child: SlideAnimation(
                    horizontalOffset: 300, // 오른쪽에서 왼쪽으로 슬라이드 거리
                    child: FadeInAnimation(
                      child: GestureDetector(
                        // 할 일 항목 탭 시 바텀 시트 표시
                        onTap: () => _showBottomSheet(context, task),
                        // TaskTile 위젯으로 할 일 정보 표시
                        child: TaskTile(task),
                      ),
                    ),
                  ),
                );
              },
              // 전체 할 일 목록 길이만큼 항목 생성
              itemCount: _taskController.taskList.length,
            ),
          );
        }
      }),
    );
  }

  // 할 일이 없을 때 표시할 메시지 생성 메소드
  _noTaskMsg() {
    return Stack(
      children: [
        // 애니메이션 효과가 적용된 포지션드 위젯
        AnimatedPositioned(
          // 애니메이션 지속 시간 설정
          duration: const Duration(milliseconds: 2000),
          child: RefreshIndicator(
            // 당겨서 새로고침 기능 설정
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              child: Wrap(
                // 콘텐츠를 가운데 정렬
                alignment: WrapAlignment.center,
                // 교차 축을 가운데로 정렬
                crossAxisAlignment: WrapCrossAlignment.center,
                // 화면 방향에 따라 래핑 방향 설정 (가로/세로)
                direction: SizeConfig.orientation == Orientation.landscape
                    ? Axis.horizontal // 가로 모드일 때 가로 방향으로 래핑
                    : Axis.vertical, // 세로 모드일 때 세로 방향으로 래핑
                children: [
                  // 화면 방향에 따라 다른 여백 설정
                  SizeConfig.orientation == Orientation.landscape
                      ? const SizedBox(
                          height: 6, // 가로 모드일 때 작은 여백
                        )
                      : const SizedBox(
                          height: 220, // 세로 모드일 때 큰 여백
                        ),
                  // 할 일 없음을 표시하는 SVG 이미지
                  SvgPicture.asset(
                    'images/task.svg',
                    // ignore: deprecated_member_use
                    color: primaryClr.withOpacity(0.5), // 투명도가 적용된 기본 색상
                    height: 90, // 이미지 높이
                    semanticsLabel: 'Task', // 접근성을 위한 레이블
                  ),
                  // 안내 메시지 텍스트
                  Padding(
                    // 좌우 30, 상하 10의 여백 설정
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    child: Text(
                      // 할 일이 없을 때 표시할 안내 메시지
                      '아직 할 일이 없습니다!\n새로운 할 일을 추가하여 하루를 생산적으로 만드세요.',
                      style: subTitleStyle, // 서브 타이틀 스타일 적용
                      textAlign: TextAlign.center, // 텍스트 가운데 정렬
                    ),
                  ),
                  // 화면 방향에 따라 하단 여백 설정
                  SizeConfig.orientation == Orientation.landscape
                      ? const SizedBox(
                          height: 120, // 가로 모드일 때 중간 크기 여백
                        )
                      : const SizedBox(
                          height: 180, // 세로 모드일 때 큰 여백
                        ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  // 할 일 항목 터치 시 바텀 시트 표시 메소드
  _showBottomSheet(BuildContext context, Task task) {
    // 분리된 TaskBottomSheet 위젯을 사용하여 바텀 시트 표시
    TaskBottomSheet.showBottomSheet(context, task, _taskController);
  }
}
