// Flutter 머티리얼 디자인 위젯을 사용하기 위한 패키지
import 'package:flutter/material.dart';
// GetX 상태관리 패키지 - 네비게이션, 상태관리 등에 사용
import 'package:get/get.dart';
// 날짜 및 시간 포맷팅을 위한 패키지
import 'package:intl/intl.dart';
// 할일 관리를 위한 컨트롤러
import 'package:todo/controllers/task_controller.dart';
// 앱의 테마 정보(색상, 텍스트 스타일 등)를 포함한 파일
import 'package:todo/ui/theme.dart';
// 커스텀 버튼 위젯
import 'package:todo/ui/widgets/button.dart';
// 할일 모델 클래스
import '../../models/task.dart';
// 커스텀 입력 필드 위젯
import '../widgets/input_field.dart';
// 음성 인식을 통한 텍스트 입력 페이지
import 'add_speech_to_text.dart';

/// 할일 추가 화면 위젯
/// 사용자가 새로운 할일을 입력하고 추가하는 화면
class AddTaskPage extends StatefulWidget {
  final String? initialTaskContent;
  // 생성자
  const AddTaskPage({Key? key, this.initialTaskContent}) : super(key: key);

  // StatefulWidget의 State 객체 생성
  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

/// 할일 추가 화면의 상태를 관리하는 State 클래스
class _AddTaskPageState extends State<AddTaskPage> {
  // 할일 관리를 위한 컨트롤러 인스턴스 생성
  final TaskController _taskController = Get.put(TaskController());

  // 할일 제목 입력을 위한 컨트롤러
  final TextEditingController _titleController = TextEditingController();
  // 할일 내용 입력을 위한 컨트롤러
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.initialTaskContent);
  }

  // 현재 날짜를 기본값으로 설정
  DateTime _selectedDate = DateTime.now();
  // 시작 시간 - 현재 시간으로 초기화
  String _startTime = DateFormat('hh:mm a').format(DateTime.now()).toString();
  // 종료 시간 - 현재 시간에서 15분 후로 초기화
  String _endTime = DateFormat('hh:mm a')
      .format(DateTime.now().add(const Duration(minutes: 15)))
      .toString();

  // 알림 시간 (분 단위) - 기본값 5분
  int _selectedRemind = 5;
  // 알림 시간 옵션 목록 (분 단위)
  List<int> remindList = [5, 10, 15, 20];
  // 반복 주기 - 기본값 '없음'
  String _selectedRepeat = '없음';
  // 반복 주기 옵션 목록
  List<String> repeatList = ['없음', '매일', '매주', '매월'];

  // 선택된 색상 인덱스 - 기본값 0(갈색)
  int _selectedColor = 0;

  // 위젯 빌드 메소드 오버라이드
  // 화면 UI를 구성하는 부분
  @override
  Widget build(BuildContext context) {
    // 화면 구조 정의
    return Scaffold(
      // ignore: deprecated_member_use
      // 화면 배경색 설정
      backgroundColor: context.theme.scaffoldBackgroundColor,
      // 커스텀 앱바 적용
      appBar: _customAppBar(),
      // 화면 본문
      body: Container(
        // 좌우 여백 10
        padding: const EdgeInsets.symmetric(horizontal: 10),
        // 스크롤 가능하도록 설정
        child: SingleChildScrollView(
          // 세로 배치 레이아웃
          child: Column(
            children: [
              // 페이지 제목
              Text(
                '할 일 추가',
                style: headingStyle,
              ),
              // 제목 입력 필드와 음성 인식 버튼 행
              Row(
                children: [
                  // 제목 입력 필드 - 가로 공간 차지
                  Expanded(
                    child: InputField(
                      title: '제목',
                      hint: '제목을 입력하세요',
                      controller: _titleController,
                    ),
                  ),
                  // 음성 인식 버튼
                  Container(
                    margin: const EdgeInsets.only(top: 52, right: 1), // Increased top margin to lower the icon
                    child: IconButton(
                      icon: const Icon(
                        // 마이크 아이콘
                        Icons.mic,
                        // 아이콘 색상: 기본 테마 색상
                        color: primaryClr, // Changed to white
                        // 아이콘 크기: 30
                        size: 30,
                      ),
                      // 음성 인식 화면으로 이동
                      onPressed: () async {
                        // 음성 인식 페이지로 이동하여 결과 값 받아오기
                        final result =
                            await Get.to(() => const AddSpeechToTextPage());
                        // 결과가 있으면 제목 필드에 적용
                        if (result != null) {
                          setState(() {
                            _titleController.text = result;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              // 내용 입력 필드
              InputField(
                title: '내용',
                hint: '내용을 입력하세요',
                controller: _noteController,
              ),
              // 날짜 선택 필드
              InputField(
                title: '날짜',
                // 현재 선택된 날짜 표시
                hint: DateFormat.yMd().format(_selectedDate),
                // 달력 아이콘 버튼
                widget: IconButton(
                  // 달력 팝업 표시
                  onPressed: () => _getDateFromUser(),
                  icon: Icon(
                    // 달력 아이콘
                    Icons.calendar_today_outlined,
                    // 아이콘 색상: 회색
                    color: primaryClr,
                  ),
                ),
              ),
              // 시작 및 종료 시간 입력 필드 행
              Row(
                children: [
                  // 시작 시간 필드 - 가로 공간의 절반 차지
                  Expanded(
                    child: InputField(
                      title: '시작 시간',
                      // 현재 선택된 시작 시간 표시
                      hint: _startTime,
                      // 시계 아이콘 버튼
                      widget: IconButton(
                        // 시간 선택 팝업 표시 (시작 시간용)
                        onPressed: () => _getTimeFromUser(isStartTime: true),
                        icon: Icon(
                          // 시계 아이콘
                          Icons.access_time_rounded,
                          // 아이콘 색상: 회색
                          color: primaryClr,
                        ),
                      ),
                    ),
                  ),
                  // 두 필드 사이의 여백
                  const SizedBox(
                    width: 12,
                  ),
                  // 종료 시간 필드 - 가로 공간의 절반 차지
                  Expanded(
                    child: InputField(
                      title: '종료 시간',
                      // 현재 선택된 종료 시간 표시
                      hint: _endTime,
                      // 시계 아이콘 버튼
                      widget: IconButton(
                        // 시간 선택 팝업 표시 (종료 시간용)
                        onPressed: () => _getTimeFromUser(isStartTime: false),
                        icon: Icon(
                          // 시계 아이콘
                          Icons.access_time_rounded,
                          // 아이콘 색상: 회색
                          color: primaryClr,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // 알림 시간 선택 필드
              InputField(
                title: '알림',
                // 현재 선택된 알림 시간 표시
                hint: '$_selectedRemind 분 전',
                // 드롭다운 메뉴 위젯
                widget: Row(
                  children: [
                    // 알림 시간 선택을 위한 드롭다운 버튼
                    DropdownButton<String>(
                      // 드롭다운 배경색: 회색계열
                      dropdownColor: Colors.blueGrey,
                      // 드롭다운 모서리 반경 10
                      borderRadius: BorderRadius.circular(10),
                      // 알림 시간 목록을 드롭다운 아이템으로 변환
                      items: remindList
                          .map<DropdownMenuItem<String>>((
                            int value,
                          ) =>
                              DropdownMenuItem<String>(
                                value: value.toString(),
                                child: Text(
                                  '$value',
                                  style: const TextStyle(
                                    // 텍스트 색상: 흰색
                                    color: Colors.white,
                                  ),
                                ),
                              ))
                          .toList(),
                      // 드롭다운 화살표 아이콘
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        // 아이콘 색상: 회색
                        color: Colors.grey,
                      ),
                      // 아이콘 크기: 32
                      iconSize: 32,
                      // 드롭다운 메뉴 그림자 높이
                      elevation: 4,
                      // 밑줄 제거
                      underline: Container(height: 0),
                      // 텍스트 스타일
                      style: subTitleStyle,
                      // 값이 변경되었을 때 호출되는 콜백
                      onChanged: (String? newValue) {
                        setState(() {
                          // 선택된 알림 시간 값 업데이트
                          _selectedRemind = int.parse(newValue!);
                        });
                      },
                    ),
                    // 여백
                    const SizedBox(
                      width: 6,
                    ),
                  ],
                ),
              ),
              // 반복 주기 선택 필드
              InputField(
                title: '반복',
                // 현재 선택된 반복 주기 표시
                hint: _selectedRepeat,
                // 드롭다운 메뉴 위젯
                widget: Row(
                  children: [
                    // 반복 주기 선택을 위한 드롭다운 버튼
                    DropdownButton<String>(
                      // 드롭다운 배경색: 회색계열
                      dropdownColor: Colors.blueGrey,
                      // 드롭다운 모서리 반경 10
                      borderRadius: BorderRadius.circular(10),
                      // 반복 주기 목록을 드롭다운 아이템으로 변환
                      items: repeatList
                          .map<DropdownMenuItem<String>>((
                            String value,
                          ) =>
                              DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    // 텍스트 색상: 흰색
                                    color: Colors.white,
                                  ),
                                ),
                              ))
                          .toList(),
                      // 드롭다운 화살표 아이콘
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        // 아이콘 색상: 회색
                        color: Colors.grey,
                      ),
                      // 아이콘 크기: 32
                      iconSize: 32,
                      // 드롭다운 메뉴 그림자 높이
                      elevation: 4,
                      // 밑줄 제거
                      underline: Container(height: 0),
                      // 텍스트 스타일
                      style: subTitleStyle,
                      // 값이 변경되었을 때 호출되는 콜백
                      onChanged: (String? newValue) {
                        setState(() {
                          // 선택된 반복 주기 값 업데이트
                          _selectedRepeat = newValue!;
                        });
                      },
                    ),
                    // 여백
                    const SizedBox(
                      width: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              // 색상 팔레트와 생성 버튼 행
              Row(
                // 양쪽 끝에 배치
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // 수직 중앙 정렬
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 색상 팔레트 위젯
                  _colorPalette(),
                  // 할일 생성 버튼
                  MyButton(
                    label: '생성하기',
                    // 버튼 클릭시 데이터 유효성 검사 후 저장
                    onTap: () => _validateData(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 커스텀 앱바 생성 메소드
  AppBar _customAppBar() {
    return AppBar(
      // 왼쪽 뒤로가기 버튼
      leading: IconButton(
        // 클릭시 이전 화면으로 돌아가기
        onPressed: () => Get.back(),
        icon: const Icon(
          // 뒤로가기 화살표 아이콘
          Icons.arrow_back_ios,
          // 아이콘 크기: 24
          size: 24,
          // 아이콘 색상: 기본 테마 색상
          color: primaryClr,
        ),
      ),
      // 앱바 그림자 제거
      elevation: 0,
      // ignore: deprecated_member_use
      // 앱바 배경색: 현재 테마의 배경색과 동일하게 설정
      backgroundColor: context.theme.scaffoldBackgroundColor,
      // 오른쪽 액션 버튼들
      actions: const [
        // 사용자 프로필 이미지
        CircleAvatar(
          backgroundImage: AssetImage('images/person.jpeg'),
          // 프로필 이미지 반경: 18
          radius: 18,
        ),
        // 오른쪽 여백
        SizedBox(
          width: 20,
        ),
      ],
      // 제목 중앙 정렬
      centerTitle: true,
    );
  }

  // 입력된 데이터의 유효성 검사 메소드
  _validateData() {
    // 제목과 내용이 모두 입력되었는지 확인
    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      // 데이터베이스에 할일 추가
      _addTasksToDb();
      // 이전 화면으로 돌아가기
      Get.back();
    }
    // 제목이나 내용 중 하나만 입력된 경우
    else if (_titleController.text.isNotEmpty ||
        _noteController.text.isNotEmpty) {
      // 오류 메시지 표시
      Get.snackbar('필수', '모든 필드를 입력해주세요!',
          // 화면 하단에 표시
          snackPosition: SnackPosition.BOTTOM,
          // 배경색: 흰색
          backgroundColor: Colors.white,
          // 텍스트 색상: 분홍색
          colorText: pinkClr,
          // 경고 아이콘 표시
          icon: const Icon(
            Icons.warning_amber_rounded,
            // 아이콘 색상: 빨간색
            color: Colors.red,
          ));
    }
    // 아무것도 입력되지 않은 경우
    else {
      // 디버그용 오류 메시지 출력
      print(
          '############################ SOMETHING WRONG HAPPENED #############################');
    }
  }

  // 데이터베이스에 할일 추가하는 메소드
  _addTasksToDb() async {
    try {
      // 컨트롤러를 통해 할일 추가
      int value = await _taskController.addTask(
        // 새로운 할일 객체 생성
        task: Task(
          // 입력된 제목
          title: _titleController.text,
          // 입력된 내용
          note: _noteController.text,
          // 완료 여부 (0: 미완료)
          isCompleted: 0,
          // 선택된 날짜
          date: DateFormat.yMd().format(_selectedDate),
          // 시작 시간
          startTime: _startTime,
          // 종료 시간
          endTime: _endTime,
          // 선택된 색상
          color: _selectedColor,
          // 알림 시간
          remind: _selectedRemind,
          // 반복 주기
          repeat: _selectedRepeat,
        ),
      );
      // 디버그용 추가된 할일 ID 출력
      print('Value: $value');
    } catch (e) {
      // 오류 발생시 오류 로그 출력
      print('error: $e');
    }
  }

  // 색상 팔레트 위젯 생성 메소드
  Column _colorPalette() {
    return Column(
      // 좌측 정렬
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 색상 선택 제목
        Text(
          '색상',
          style: titleStyle,
        ),
        // 제목과 색상 선택기 사이 여백
        const SizedBox(
          height: 8,
        ),
        // 색상 옵션들을 유연하게 배치
        Wrap(
          // 3가지 색상 옵션 생성
          children: List<Widget>.generate(
            3,
            (index) => GestureDetector(
              // 색상 클릭시 호출되는 콜백
              onTap: () {
                setState(() {
                  // 선택된 색상 인덱스 업데이트
                  _selectedColor = index;
                });
              },
              child: Padding(
                // 색상 옵션 사이 여백
                padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                // 원형 색상 아바타
                child: CircleAvatar(
                  // 인덱스에 따라 다른 색상 적용
                  backgroundColor: index == 0
                      ? primaryClr // 파란색
                      : index == 1
                          ? pinkClr // 분홍색
                          : orangeClr, // 주황색
                  // 원 반경: 14
                  radius: 14,
                  // 현재 선택된 색상이면 체크 아이콘 표시
                  child: _selectedColor == index
                      ? const Icon(
                          // 체크 아이콘
                          Icons.done,
                          // 아이콘 크기: 16
                          size: 16,
                          // 아이콘 색상: 흰색
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 사용자로부터 날짜 선택받는 메소드
  _getDateFromUser() async {
    // 날짜 선택 대화상자 표시
    DateTime? pickedDate = await showDatePicker(
      context: context,
      // 초기 선택 날짜: 현재 선택된 날짜
      initialDate: _selectedDate,
      // 선택 가능한 최소 날짜: 2015년
      firstDate: DateTime(2015),
      // 선택 가능한 최대 날짜: 2030년
      lastDate: DateTime(2030),
    );

    // 날짜가 선택되었는지 확인
    if (pickedDate != null) {
      setState(() {
        // 선택된 날짜로 상태 업데이트
        _selectedDate = pickedDate;
      });
    } else {
      // 날짜가 선택되지 않은 경우 디버그 메시지
      print('It\'s null or something is wrong');
    }
  }

  // 사용자로부터 시간 선택받는 메소드
  _getTimeFromUser({required bool isStartTime}) async {
    // 시간 선택 대화상자 표시
    TimeOfDay? pickedTime = await showTimePicker(
      // 시간 입력 모드: 키보드 입력 모드
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
      // 초기 선택 시간 설정
      initialTime: isStartTime
          ? TimeOfDay.fromDateTime(DateTime.now()) // 시작 시간은 현재 시간
          : TimeOfDay.fromDateTime(
              DateTime.now().add(
                const Duration(minutes: 15), // 종료 시간은 현재 시간 + 15분
              ),
            ),
    );

    // 선택된 시간을 형식화
    String formattedTime = pickedTime!.format(context);

    // 시작 시간인 경우
    if (isStartTime) {
      setState(() {
        // 시작 시간 업데이트
        _startTime = formattedTime;
      });
    }
    // 종료 시간인 경우
    else if (!isStartTime) {
      setState(() {
        // 종료 시간 업데이트
        _endTime = formattedTime;
      });
    }
    // 오류 처리
    else {
      // 디버그 용 오류 메시지
      print('Something went wrong');
    }
  }
}
