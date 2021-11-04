TITLE : C# Garbage Collector


# 매니지드 언어
---

GC에 의해 자동으로 힙 메모리가 관리되는 프로그래밍 언어를 `Managed Language`라고 한다.

매니지드 언어는 프로그래머가 할당은 직접 하지만

GC(가비지 컬렉터)가 더이상 사용되지 않는 힙 메모리의 객체를 자동으로 수거한다.

대표적인 언어로 `C#`, `Java`, `Python` 등이 있다.

<br>

반면, GC가 없는 프로그래밍 언어를 `Unmanaged Language`라고 한다.

언매니지드 언어는 프로그래머가 직접 객체의 힙 메모리에 대한 할당, 해제를 직접 수행한다.

대표적인 언어로 `C`, `C++` 등이 있다.

<br>



# 가비지란?
---

힙 메모리에 할당되었다가, 더이상 참조되지 않아서 GC의 수거(메모리 해제) 대상이 되는 객체

<br>



# 힙 할당 자체가 문제가 되나?
---

힙 메모리 할당 자체는 문제가 되지 않는다.

<br>



# 가비지 수거는 언제 발생하나?
---

- 세대(0, 1, 2) 별 메모리 저장 한계를 넘을 때

- `GC.Collect()` 메소드를 호출할 때

- 시스템 메모리가 부족할 때

<br>



# 그래서 GC가 하는 일은?
---

힙 메모리에 할당된 객체들의 참조 카운트를 검사하여,

참조 카운트가 0인(아무도 참조하지 않는) 객체를 메모리에서 해제한다.

따라서 힙 메모리 중간중간에 비어버리는 영역들이 생기는데,

힙 메모리의 객체들을 앞에서부터 재배치하여, 빈 영역들을 채워준다.

<br>



# 그래서 진짜로 문제되는 것은?
---

GC가 작동할 때,

사용되지 않는 힙 메모리 영역의 수거와 메모리 재배치가 발생할 때

프로그램 자체가 멈춰버린다는 것이 문제가 된다.

따라서 가비지가 많아서 GC가 할일이 많아진다면

GC의 작동 시간이 더 길어지고, 프로그램이 멈추는 시간이 더 길어진다.

<br>



# GC의 작동 방식
---
- 힙 할당
- 참조 카운트
- 세대(0, 1, 2)
- 자동 힙 메모리 수거






# References
---
<!-- 닷넷 GC -->
- <https://docs.microsoft.com/ko-kr/dotnet/standard/garbage-collection/fundamentals>
- <https://docs.microsoft.com/ko-kr/dotnet/standard/garbage-collection/performance>
- <https://docs.microsoft.com/ko-kr/dotnet/standard/garbage-collection/large-object-heap>
- <https://stackify.com/c-garbage-collection/>
- <https://luv-n-interest.tistory.com/922>
- <https://plumbr.io/handbook/garbage-collection-algorithms>
- <https://plumbr.io/handbook/garbage-collection-algorithms-implementations>
- <>

<!-- 유니티 C# GC -->
- <https://docs.unity3d.com/Manual/performance-managed-memory.html>
- <https://docs.unity3d.com/Manual/performance-garbage-collector.html>
- <https://docs.unity3d.com/Manual/performance-incremental-garbage-collection.html>
- <https://pizzasheepsdev.tistory.com/12>

<!-- 매니지드, 언매니지드 힙 -->
- <https://diehard98.tistory.com/entry/Managed-코드-Unmanaged-코드-그리고-Native-코드에-대한-이야기>
- <https://www.csharpstudy.com/DevNote/Article/5>
- <https://jafm00n.tistory.com/41>
- <https://stackoverflow.com/questions/6621716/managed-and-unmanaged-heap>
- <https://penspanic.github.io/csharp_dotnet/2020/10/01/csharp-unmanaged-memory/>
- <>
- <>








