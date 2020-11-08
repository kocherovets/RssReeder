Целью создания RssReeder было продемонстрировать набор приемов и методик создания iOS приложений с помощью библиотеки ReduxVM, которые напрямую не следуют из самой библиотеки, но позволяют легко создавать хорошо задокументированные, поддерживаемые и протестированные проекты.

<img width="800" alt="Screenshot 2020-02-08 at 22 55 43" src="https://user-images.githubusercontent.com/4235844/98244789-0b8d8b80-1f81-11eb-9f9b-7a07254bfe7e.jpeg">
Разработку лучше всего начать с разработки диаграммы активностей подобной приведенной здесь. Блоки представляют собой все активности в системе, которые инициируются внешними по отношению к системе источниками. Например, действиями пользователя через UI или появлением данных из сетевых сокетов. Никаких строгих правил нет, нужно только чтобы диаграмма была достаточно читабельна. 

Каждый блок представляет собой список экшенов и сайдэффектов, из которых состоит эта активность. Часто после выполнения некоторой уникальной работы для данной активности нужно выполнить общую работу для нескольких активностей. Тогда в диаграмме переход к нужному списку рисуется с помощью стрелки. Например, при добавлении нового источника новостей, нужно выполнить сначала уникальную задачу по добавлению этого источника в стейт и сохранению этого источника в базе данных, а потом список операций по получению новостей из этого источника и обновлению списков новостей в стейте с учетом этих новых новостей.

В диаграмме информация, значимая для UI представлена в виде тэгов. Если для какого-то экшена задан тег, например, UISettings, то это означает, что UI отображающий информацию о настройках должен обновиться.

Если инструмент построения диаграмм позволяет, то можно дополнить отдельные пункты заметками, чтобы диаграмму было легче понимать новым людям.

Теперь перечислю несколько правил, как можно организовать код, чтобы с ним было удобно работать.

1. Тэги для срабатывания UI можно делать в виде пустых протоколов и просто помечать им нужные Action. А в презентере нужно при проверке срабатывания проверять, что последний Action удовлетворяет этому протоколу. При этом презентер при подписке к событиям в стейте сработает независимо от этого условия, что бывает при создании вьюконтроллера или возврату к нему, если экран ранее ушел с верха иерархии. Так что можно не бояться, что UI окажется с устаревшей информацией.

2. При проектировании сайдэффектов лучше придерживаться какого-то стандарта, чтобы их структура была привычной и не требовала дополнительных усилий на восприятие при работе с кодом. При этом структура может быть нарушена, но должно быть какое-то обоснование и понимание, почему в данном конкретном случае сделали по другому. Я предлагаю такую структуру. 

SE
  - StartAction
  - condition()
  - execute()
  - FinishAction

StartAction или FinishAction могут остутствовать, если они не нужны. Я рекомендую всегда делать FinishAction, если далее должен сработать какой-то еще сайдэффект. В этом случае FinishAction выступает в роли крючка, за который цепляется следующий сайдэффект.

Альтернативой является прямой вызов StartAction следующего сайдэффекта из execute(). Но у этого подхода есть два минуса. Первое, можно перейти только на один следующий сайдффект. И если потребуется добавить, например, аналитику на эту операцию, то нужно будет что-то менять. Второе, когда мы открываем какой-то сайдэффект для работы, то не видно в каких случаях он запускается. Это особенно неудобно, когда таких случаев много. В приложении это, например, LoadNewsSE.

Ну и если это конец цепочки операций, то в конце обычно из execute() вызывается Action меняющий что-то в стейте.

Аналитику можно сделать конечно и через Middleware, но из своего опыта я бы рекомендовал придерживаться именно такой схемы, если у вас нет особых причин делать по другому.

3. Если придерживаться такого подхода, то диаграмму можно сократить убрав везде StartAction и FinishAction без особой потери информативности.

4. Весь код по диаграмме можно оформить отдельным фреймворком, чтобы его можно было подключать, например, к разным UI таргетам. В этом проекте для примера сделаны таргет на основе UIKit и таргет на основе SwiftUI с общим скейтом и логикой его обслуживающей. Отмечу, что таргет со SwiftUI является исключительно демонстрационным, так как я пока что плохо знаю SwiftUI. 
Также выделение во фреймворк позволяет скрыть детали реализации выставив наружу только необходимый минимум.

5. Правила проектирование стейта не рассматриваются в этом проекте. Но есть хорошее видео, где можно посмотреть идеи по этой теме для крупных проектов. https://www.youtube.com/watch?v=c90jUnAbeR4

