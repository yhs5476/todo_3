// Flutter 기본 위젯 및 Material 디자인 요소를 위한 패키지
import 'package:flutter/material.dart';
// 로컬 알림 기능을 제공하는 패키지
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// GetX 상태 관리 및 라우팅 패키지
import 'package:get/get.dart';
// 날짜 및 시간 형식 지정을 위한 패키지
import 'package:intl/intl.dart';
// 반응형 프로그래밍을 위한 RxDart 패키지
import 'package:rxdart/rxdart.dart';
// 시간대 처리를 위한 timezone 패키지
import 'package:timezone/timezone.dart' as tz;
// 최신 시간대 데이터를 제공하는 패키지
import 'package:timezone/data/latest.dart' as tz;
// 할일 모델 클래스
import '/models/task.dart';
// 기기의 현재 시간대 정보를 가져오기 위한 패키지
import 'package:flutter_timezone/flutter_timezone.dart';

// 알림 관리를 위한 클래스
class NotifyHelper {
  // Flutter 로컬 알림 플러그인 인스턴스 생성
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 선택된 알림의 페이로드 문자열 저장
  String selectedNotificationPayload = '';

  // 알림 선택 이벤트를 관찰하기 위한 BehaviorSubject
  // RxDart의 BehaviorSubject는 가장 최근 값을 기억하고 새로운 구독자에게 전달하는 특성을 가짐
  final BehaviorSubject<String> selectNotificationSubject =
      BehaviorSubject<String>();

  // 알림 기능 초기화 메소드
  initializeNotification() async {
    // 시간대 데이터 초기화
    tz.initializeTimeZones();
    // 알림 선택 이벤트 처리를 위한 설정
    _configureSelectNotificationSubject();
    // 로컬 시간대 설정
    await _configureLocalTimeZone();
    // iOS 권한 요청 기능 (현재 비활성화됨)
    // await requestIOSPermissions(flutterLocalNotificationsPlugin);

    // iOS용 알림 초기화 설정
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      // 소리 권한 요청 안함
      requestSoundPermission: false,
      // 배지 권한 요청 안함
      requestBadgePermission: false,
      // 알림 권한 요청 안함
      requestAlertPermission: false,
      // iOS에서 알림을 받았을 때 호출되는 콜백 함수
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    // 안드로이드용 알림 초기화 설정 (앱 아이콘 사용)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('appicon');

    // 모든 플랫폼을 위한 초기화 설정 통합
    final InitializationSettings initializationSettings =
        InitializationSettings(
      iOS: initializationSettingsIOS,
      android: initializationSettingsAndroid,
    );

    // 알림 플러그인 초기화
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // 알림을 터치했을 때 호출되는 콜백 함수
      onDidReceiveNotificationResponse: (NotificationResponse? payload) async {
        if (payload != null) {
          // 디버그용 알림 내용 출력
          debugPrint('notification payload: $payload');
        }
        // 알림 페이로드를 BehaviorSubject에 추가하여 구독자에게 전달
        selectNotificationSubject.add(payload.toString());
      },
    );
  }

  // 즉시 알림을 표시하는 메소드
  displayNotification({required String title, required String body}) async {
    // 테스트용 로그 출력
    print('doing test');

    // 안드로이드용 알림 채널 설정
    var androidPlatformChannelSpecifics =
        const AndroidNotificationDetails('your channel id', 'your channel name',
            // 채널 설명
            channelDescription: 'your channel description',
            // 알림 중요도: 최대
            importance: Importance.max,
            // 알림 우선순위: 높음
            priority: Priority.high);

    // iOS용 알림 설정 (기본 설정 사용)
    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();

    // 모든 플랫폼을 위한 알림 설정 통합
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    // 알림 표시
    await flutterLocalNotificationsPlugin.show(
      0, // 알림 ID (0은 항상 같은 알림을 대체함)
      title, // 알림 제목
      body, // 알림 내용
      platformChannelSpecifics, // 플랫폼별 알림 설정
      payload: 'Default_Sound', // 알림 클릭시 전달될 추가 데이터
    );
  }

  // 특정 할일에 대한 알림 취소 메소드
  cancelNotification(Task task) async {
    // 할일 ID를 사용하여 해당 알림만 취소
    await flutterLocalNotificationsPlugin.cancel(task.id!);
    // 디버그용 알림 취소 로그
    print('Notification is canceled');
  }

  // 모든 알림 취소 메소드
  cancelAllNotifications() async {
    // 모든 알림 취소
    await flutterLocalNotificationsPlugin.cancelAll();
    // 디버그용 알림 취소 로그
    print('Notification is canceled');
  }

  // 예약된 알림 스케줄링 메소드
  scheduledNotification(int hour, int minutes, Task task) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id!, // 알림 ID로 할일 ID 사용
      task.title, // 알림 제목으로 할일 제목 사용
      task.note, // 알림 내용으로 할일 내용 사용
      //tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),  // 테스트용 5초 후 알림 (주석 처리됨)

      // 알림을 표시할 다음 시간 계산
      _nextInstanceOfTenAM(
          hour, minutes, task.remind!, task.repeat!, task.date!),

      // 알림 설정
      const NotificationDetails(
        android: AndroidNotificationDetails(
            'your channel id', 'your channel name',
            channelDescription: 'your channel description'),
      ),

      // 기기가 절전 모드에서도 알림이 작동하도록 허용 (더 이상 사용되지 않는 속성이지만 후방 호환성을 위해 유지)
      // ignore: deprecated_member_use
      androidAllowWhileIdle: true,

      // 시간 해석 방법: 절대 시간 (시간대 고려)
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,

      // 시간 구성요소 일치 조건: 시간만 일치하면 알림 발생 (반복 알림을 위해 필요)
      matchDateTimeComponents: DateTimeComponents.time,

      // 알림 클릭시 전달될 페이로드 (제목, 내용, 시작시간을 구분자로 구분하여 전달)
      payload: '${task.title}|${task.note}|${task.startTime}|',
    );
  }

  // 다음 알림 시간을 계산하는 메소드
  tz.TZDateTime _nextInstanceOfTenAM(
      int hour, int minutes, int remind, String repeat, String date) {
    // 현재 시간 가져오기
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    // 문자열 날짜를 날짜 객체로 변환
    var formattedDate = DateFormat.yMd().parse(date);

    // 현재 시간대에 맞는 날짜 객체 생성
    final tz.TZDateTime fd = tz.TZDateTime.from(formattedDate, tz.local);

    // 예약된 알림 시간 설정 (년, 월, 일, 시, 분)
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, fd.year, fd.month, fd.day, hour, minutes);

    // 알림 시간에서 알림 설정 시간(분)만큼 빠른 시간으로 조정
    scheduledDate = afterRemind(remind, scheduledDate);

    // 예약 시간이 현재 시간보다 이전이면 반복 설정에 따라 다음 시간 계산
    if (scheduledDate.isBefore(now)) {
      // 매일 반복인 경우 다음 날로 설정
      if (repeat == 'Daily') {
        scheduledDate = tz.TZDateTime(tz.local, now.year, now.month,
            (formattedDate.day) + 1, hour, minutes);
      }
      // 매주 반복인 경우 7일 후로 설정
      if (repeat == 'Weekly') {
        scheduledDate = tz.TZDateTime(tz.local, now.year, now.month,
            (formattedDate.day) + 7, hour, minutes);
      }
      // 매월 반복인 경우 다음 달로 설정
      if (repeat == 'Monthly') {
        scheduledDate = tz.TZDateTime(tz.local, now.year,
            (formattedDate.month) + 1, formattedDate.day, hour, minutes);
      }
      // 조정된 시간에서 알림 설정 시간(분)만큼 빠른 시간으로 재조정
      scheduledDate = afterRemind(remind, scheduledDate);
    }

    // 디버그용 다음 예약 시간 출력
    print('Next scheduledDate = $scheduledDate');

    return scheduledDate;
  }

  // 알림 시간을 설정된 분만큼 앞당기는 메소드
  tz.TZDateTime afterRemind(int remind, tz.TZDateTime scheduledDate) {
    // 5분 전 알림 설정
    if (remind == 5) {
      scheduledDate = scheduledDate.subtract(const Duration(minutes: 5));
    }
    // 10분 전 알림 설정
    if (remind == 10) {
      scheduledDate = scheduledDate.subtract(const Duration(minutes: 10));
    }
    // 15분 전 알림 설정
    if (remind == 15) {
      scheduledDate = scheduledDate.subtract(const Duration(minutes: 15));
    }
    // 20분 전 알림 설정
    if (remind == 20) {
      scheduledDate = scheduledDate.subtract(const Duration(minutes: 20));
    }
    return scheduledDate;
  }

  // iOS 알림 권한 요청 메소드
  void requestIOSPermissions() {
    // iOS 플랫폼에 특화된 구현체 가져오기
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        // 권한 요청
        ?.requestPermissions(
          // 알림 표시 권한
          alert: true,
          // 앱 아이콘에 배지 표시 권한
          badge: true,
          // 알림 소리 재생 권한
          sound: true,
        );
  }

  // 로컬 시간대 설정 메소드
  Future<void> _configureLocalTimeZone() async {
    // 시간대 데이터 초기화
    tz.initializeTimeZones();
    // 현재 기기의 시간대 이름 가져오기
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    // 가져온 시간대를 timezone 패키지의 로컬 위치로 설정
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

/*   Future selectNotification(String? payload) async {
    if (payload != null) {
      //selectedNotificationPayload = "The best";
      selectNotificationSubject.add(payload);
      print('notification payload: $payload');
    } else {
      print("Notification Done");
    }
    Get.to(() => SecondScreen(selectedNotificationPayload));
  } */

  // 이전 iOS 버전을 위한 알림 수신 처리 메소드
  Future onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // 알림 세부 정보를 포함한 대화상자 표시, OK를 터치하면 다른 페이지로 이동
    /* showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Title'),  // 알림 제목
        content: const Text('Body'),  // 알림 내용
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Ok'),  // 확인 버튼
            onPressed: () async {
              // 대화상자 닫기
              Navigator.of(context, rootNavigator: true).pop();
              // 다른 화면으로 이동
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Container(color: Colors.white),  // 빈 화면으로 이동
                ),
              );
            },
          )
        ],
      ),
    );
 */
    Get.dialog(Text(body!));
  }

  // 알림 선택 이벤트 관찰을 위한 설정 메소드
  void _configureSelectNotificationSubject() {
    // selectNotificationSubject의 스트림을 구독하여 알림 클릭 이벤트 처리
    selectNotificationSubject.stream.listen((String payload) async {
      // 디버그용 페이로드 출력
      debugPrint('My payload is $payload');
    });
  }
}
