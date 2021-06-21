# 윈도우 CMD 명령어 모음
---

## 파이프

```
# 특정 문자열을 갖는 라인들로 필터링
| find "문자열"
| findstr "문자열"

# 정렬하기
| sort

# n번째 열의 문자로 정렬하기
| sort /+n

# 화면에 가득차면 대기하기
| more
```

<br>


## 현재 프로세스 목록

```
# 프로세스 목록 전부 출력
tasklist

# 이름, pid, ppid 출력
wmic process get name, processid, parentprocessid
```


<br>

# References
---
- <https://stackoverflow.com/questions/7486717/finding-parent-process-id-on-windows>