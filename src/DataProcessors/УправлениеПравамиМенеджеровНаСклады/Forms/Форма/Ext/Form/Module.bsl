﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ТаблицаШахматки = Новый ТаблицаЗначений;
	ТаблицаШахматки.Колонки.Добавить("Менеджер", Новый ОписаниеТипов("СправочникСсылка.Менеджеры"));

	ТабилцаСписка = РеквизитФормыВЗначение("Список");
	
	МассивДобавляемыхРеквизитов = Новый Массив;
	
	РеквизитТаблицыШахматки = Новый РеквизитФормы("Шахматка", Новый ОписаниеТипов("ТаблицаЗначений"));	
	МассивДобавляемыхРеквизитов.Добавить(РеквизитТаблицыШахматки);
	
	РеквизитМенеджер = Новый РеквизитФормы("Менеджер", ТаблицаШахматки.Колонки[0].ТипЗначения, "Шахматка");	
	МассивДобавляемыхРеквизитов.Добавить(РеквизитМенеджер);
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Менеджеры.Ссылка КАК Менеджер,
	|	Склады.Ссылка КАК Склад,
	|	ЛОЖЬ КАК ЕстьПравоНаСклад,
	|	Менеджеры.Наименование КАК МенеджерНаименование,
	|	Склады.Наименование КАК СкладНаименование,
	|	ЛОЖЬ КАК УстановленоДляСклада,
	|	ЛОЖЬ КАК УстановленоДляВсехСкладов
	|ИЗ
	|	Справочник.Менеджеры КАК Менеджеры,
	|	Справочник.Склады КАК Склады
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ПраваМенеджеровПоПродажамНаСклады.Менеджер,
	|	ПраваМенеджеровПоПродажамНаСклады.Склад,
	|	ИСТИНА,
	|	ПраваМенеджеровПоПродажамНаСклады.Менеджер.Наименование,
	|	ПраваМенеджеровПоПродажамНаСклады.Склад.Наименование,
	|	ИСТИНА,
	|	ЛОЖЬ
	|ИЗ
	|	РегистрСведений.ПраваМенеджеровПоПродажамНаСклады КАК ПраваМенеджеровПоПродажамНаСклады
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ПраваМенеджеровПоПродажамНаСклады.Менеджер,
	|	Склады.Ссылка,
	|	ИСТИНА,
	|	ПраваМенеджеровПоПродажамНаСклады.Менеджер.Наименование,
	|	Склады.Наименование,
	|	ЛОЖЬ,
	|	ИСТИНА
	|ИЗ
	|	РегистрСведений.ПраваМенеджеровПоПродажамНаСклады КАК ПраваМенеджеровПоПродажамНаСклады,
	|	Справочник.Склады КАК Склады
	|ГДЕ
	|	ПраваМенеджеровПоПродажамНаСклады.Склад = ЗНАЧЕНИЕ(Справочник.Склады.ПустаяСсылка)
	|
	|УПОРЯДОЧИТЬ ПО
	|	СкладНаименование,
	|	МенеджерНаименование
	|ИТОГИ
	|	МАКСИМУМ(ЕстьПравоНаСклад),
	|	МАКСИМУМ(СкладНаименование),
	|	МАКСИМУМ(УстановленоДляСклада),
	|	МАКСИМУМ(УстановленоДляВсехСкладов)
	|ПО
	|	Менеджер,
	|	Склад";
	
	Результат = Запрос.Выполнить();
	
	Если Не Результат.Пустой() Тогда
	
		ВыборкаПоМенеджерам = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "Менеджер");
		
		Пока ВыборкаПоМенеджерам.Следующий() Цикл
		
			цНоваяСтрока = ТаблицаШахматки.Добавить();
			цНоваяСтрока.Менеджер = ВыборкаПоМенеджерам.Менеджер;
			
			ВыборкаПоСкладам = ВыборкаПоМенеджерам.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "Склад");
			
			Пока ВыборкаПоСкладам.Следующий() Цикл
				
				Если ЗначениеЗаполнено(ВыборкаПоСкладам.Склад) Тогда
					
					цИмяКолонки = ПолучитьИмяКолонкиСкладаПоСсылкеСклада(ВыборкаПоСкладам.Склад);
					
					цКолонка = ТаблицаШахматки.Колонки.Найти(цИмяКолонки);
					
					Если цКолонка = Неопределено Тогда
						
						цКолонка = ТаблицаШахматки.Колонки.Добавить(цИмяКолонки, Новый ОписаниеТипов("Булево"), ВыборкаПоСкладам.СкладНаименование);
						
						цНовыйРеквизитТаблицыФормы = Новый РеквизитФормы(цИмяКолонки, Новый ОписаниеТипов("Булево"), "Шахматка", ВыборкаПоСкладам.СкладНаименование, Ложь);
						МассивДобавляемыхРеквизитов.Добавить(цНовыйРеквизитТаблицыФормы);
						
					КонецЕсли;
					
					цНоваяСтрока[цИмяКолонки] = ВыборкаПоСкладам.ЕстьПравоНаСклад;
					
				КонецЕсли;
				
				Если ВыборкаПоСкладам.УстановленоДляСклада Тогда
					
					цНоваяСтрокаСписка = ТабилцаСписка.Добавить();
					ЗаполнитьЗначенияСвойств(цНоваяСтрокаСписка, ВыборкаПоСкладам, "Менеджер,Склад");
					
				КонецЕсли;
				
				Если ВыборкаПоСкладам.УстановленоДляВсехСкладов Тогда
					
					цНоваяСтрокаСписка = ТабилцаСписка.Добавить();
					ЗаполнитьЗначенияСвойств(цНоваяСтрокаСписка, ВыборкаПоСкладам, "Менеджер");
					
				КонецЕсли;
			
			КонецЦикла;
		
		КонецЦикла;
		
	КонецЕсли;
	
	ТабилцаСписка.Свернуть("Менеджер,Склад");
	
	ИзменитьРеквизиты(МассивДобавляемыхРеквизитов);
	
	ЗначениеВРеквизитФормы(ТаблицаШахматки, "Шахматка");
	ЗначениеВРеквизитФормы(ТабилцаСписка, "Список");
	
	ТаблицаФормы = Элементы.Добавить("Шахматка", Тип("ТаблицаФормы"));
	ТаблицаФормы.ПутьКДанным = "Шахматка";
	ТаблицаФормы.ИзменятьПорядокСтрок = Ложь;
	ТаблицаФормы.ИзменятьСоставСтрок = Ложь;
	ТаблицаФормы.УстановитьДействие("ПриАктивизацииСтроки", "ШахматкаПриАктивизацииСтроки");
	ТаблицаФормы.УстановитьДействие("ПриИзменении", "ШахматкаПриИзменении");
	
	Элементы.Переместить(ТаблицаФормы, ЭтаФорма, Элементы.Список);
	
	ПолеМенеджер = Элементы.Добавить("ШахматкаМенеджер", Тип("ПолеФормы"), ТаблицаФормы);
	ПолеМенеджер.Вид = ВидПоляФормы.ПолеВвода;
	ПолеМенеджер.ПутьКДанным = "Шахматка.Менеджер";
	ПолеМенеджер.ТолькоПросмотр = Истина;
	
	МассивДобавляемыхРеквизитов.Удалить(0);
	МассивДобавляемыхРеквизитов.Удалить(0);
	
	Для каждого ТекРеквизит Из МассивДобавляемыхРеквизитов Цикл
		
		НовыйЭлементФормы = Элементы.Добавить(ТекРеквизит.Имя, Тип("ПолеФормы"), ТаблицаФормы);
		НовыйЭлементФормы.Вид = ВидПоляФормы.ПолеФлажка;
		НовыйЭлементФормы.ПутьКДанным = СтрШаблон("%1.%2", ТекРеквизит.Путь, ТекРеквизит.Имя);
		
	КонецЦикла;
	
	Элементы.Список.ОтборСтрок = Новый ФиксированнаяСтруктура("Менеджер");
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийТаблицыФормыШахматка

&НаКлиенте
Процедура ШахматкаПриАктивизацииСтроки(Элемент)

	ТекДанные = Элементы.Шахматка.ТекущиеДанные;
	Элементы.Список.ОтборСтрок = Новый ФиксированнаяСтруктура("Менеджер", ТекДанные.Менеджер);

КонецПроцедуры // ШахматкаПриАктивизацииСтроки()

&НаКлиенте
Процедура ШахматкаПриИзменении(Элемент)
	
	Перем НовыйСписокСкладов;
	
	ТекДанные = Элементы.Шахматка.ТекущиеДанные;
	ТекМенеджер = ТекДанные.Менеджер;
	ТекЭлемент = Элемент.ТекущийЭлемент;
	ТемИмяКолонкиСклада = ТекЭлемент.Имя;
	ТекЗначение = ТекДанные[ТемИмяКолонкиСклада];
	
	Результат = ОбработатьИзменениеФлагаШахматкиПоМенеджеруИИмениКолонкиСклада(ТекМенеджер, ТемИмяКолонкиСклада, ТекЗначение);
	
	Если Не Результат.Успех Тогда
	
		ТекДанные[ТемИмяКолонкиСклада] = Не ТекЗначение;
		
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = Результат.Сообщение;
		Сообщение.Сообщить();
		
	Иначе
		
		Если Результат.Свойство("НовыйСписокСкладов", НовыйСписокСкладов) И НовыйСписокСкладов <> Неопределено Тогда
			
			СтрокиКУдалению = Список.НайтиСтроки(Новый Структура("Менеджер", ТекМенеджер));
			
			Для каждого ТекСтрокаКУдалению Из СтрокиКУдалению Цикл
			
				Список.Удалить(ТекСтрокаКУдалению);
			
			КонецЦикла;
			
			Для каждого ТекНовыйСклад Из НовыйСписокСкладов Цикл
			
				НоваяСтрока = Список.Добавить();
				НоваяСтрока.Менеджер = ТекМенеджер;
				НоваяСтрока.Склад = ТекНовыйСклад;
			
			КонецЦикла;
		
		ИначеЕсли Не ТекЗначение Тогда
			
			СтрокиКУдалению = Список.НайтиСтроки(Новый Структура("Менеджер,Склад", ТекМенеджер, Результат.Склад));
			
			Если СтрокиКУдалению.Количество() Тогда
			
				Список.Удалить(СтрокиКУдалению[0]);
				
			КонецЕсли;
			
		Иначе
			
			НоваяСтрока = Список.Добавить();
			НоваяСтрока.Менеджер = ТекМенеджер;
			НоваяСтрока.Склад = Результат.Склад;
			
		КонецЕсли;
	
	КонецЕсли;

КонецПроцедуры // ШахматкаПриИзменении()

#КонецОбласти

#Область ОбработчикиСобытийТаблицыФормыСписок

&НаКлиенте
Процедура СписокПередУдалением(Элемент, Отказ)
	
	ТекДанные = Элементы.Список.ТекущиеДанные;
	
	СтруктураРезультата = ОбработатьИзменениеФлагаШахматкиПоМенеджеруИСкладу(ТекДанные.Менеджер, ТекДанные.Склад, Ложь);
	
	Если СтруктураРезультата.Успех Тогда
		
		ОтборСтрок = Новый Структура;
		ОтборСтрок.Вставить("Менеджер", ТекДанные.Менеджер);
		
		СтрокиИзменить = ЭтаФорма.Шахматка.НайтиСтроки(ОтборСтрок);
		
		Если СтрокиИзменить.Количество() Тогда
			
			ТекСтрока = СтрокиИзменить[0];
			
			Если СтруктураРезультата.ИмяКолонкиСклада <> Неопределено Тогда
				
				ТекСтрока[СтруктураРезультата.ИмяКолонкиСклада] = Ложь;
				
			Иначе
				
				Для каждого ТекКолонка Из Элементы.Шахматка.ПодчиненныеЭлементы Цикл
				
					Если Лев(ТекКолонка.Имя, 1) = "_" Тогда
					
						ТекСтрока[ТекКолонка.Имя] = Ложь;
					
					КонецЕсли;
				
				КонецЦикла;
				
			КонецЕсли;
			
		КонецЕсли;
		
	Иначе
		
		Отказ = Истина;
		
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = СтруктураРезультата.Сообщение;
		Сообщение.Сообщить();
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СписокПередОкончаниемРедактирования(Элемент, НоваяСтрока, ОтменаРедактирования, Отказ)
	
	Если ОтменаРедактирования Тогда
	
		Возврат;
	
	КонецЕсли;
	
	ТекДанные = Элементы.Список.ТекущиеДанные;
	
	Если Не НоваяСтрока И Не ОтменаРедактирования И ТекДанные.Склад <> СкладПредыдущееЗначение Тогда
	
		// Изменили склад, теперь необходимо удалить старую запись
		
		СтруктураРезультата = ОбработатьИзменениеФлагаШахматкиПоМенеджеруИСкладу(ТекДанные.Менеджер, СкладПредыдущееЗначение, Ложь);
		
		Если СтруктураРезультата.Успех Тогда
			
			ОтборСтрок = Новый Структура;
			ОтборСтрок.Вставить("Менеджер", ТекДанные.Менеджер);
			
			СтрокиИзменить = ЭтаФорма.Шахматка.НайтиСтроки(ОтборСтрок);
			
			Если СтрокиИзменить.Количество() Тогда
				
				ТекСтрока = СтрокиИзменить[0];
				
				Если СтруктураРезультата.ИмяКолонкиСклада <> Неопределено Тогда
					
					ТекСтрока[СтруктураРезультата.ИмяКолонкиСклада] = Ложь;
					
				Иначе
					
					Для каждого ТекКолонка Из Элементы.Шахматка.ПодчиненныеЭлементы Цикл
					
						Если Лев(ТекКолонка.Имя, 1) = "_" Тогда
						
							ТекСтрока[ТекКолонка.Имя] = Ложь;
						
						КонецЕсли;
					
					КонецЦикла;
					
				КонецЕсли;
			
			КонецЕсли;
		
		Иначе
			
			Отказ = Истина;
			
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = СтруктураРезультата.Сообщение;
			Сообщение.Сообщить();
		
		КонецЕсли;
	
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СписокПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	
	ТекДанные = Элементы.Список.ТекущиеДанные;
	
	Если НоваяСтрока И Не Копирование Тогда
		
		// Проверка на налицие текущих данных в Шахматке произведена перед началом добавления
		ТекДанные.Менеджер = Элементы.Шахматка.ТекущиеДанные.Менеджер;
		
	КонецЕсли;
	
	СкладПредыдущееЗначение = ТекДанные.Склад;
	
КонецПроцедуры

&НаКлиенте
Процедура СписокПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)
	
	Отказ = Элементы.Шахматка.ТекущиеДанные = Неопределено;
	
КонецПроцедуры

&НаКлиенте
Процедура СписокПриОкончанииРедактирования(Элемент, НоваяСтрока, ОтменаРедактирования)
	
	ТекДанные = Элементы.Список.ТекущиеДанные;
	
	Если ТекДанные = Неопределено Тогда
	
		Возврат
	
	КонецЕсли;
	
	// Изменили склад, теперь необходимо отразить изменения в регистре и на форме
	
	СтруктураРезультата = ОбработатьИзменениеФлагаШахматкиПоМенеджеруИСкладу(ТекДанные.Менеджер, ТекДанные.Склад, Истина);
	
	Если СтруктураРезультата.Успех Тогда
		
		ОтборСтрок = Новый Структура;
		ОтборСтрок.Вставить("Менеджер", ТекДанные.Менеджер);
		
		СтрокиИзменить = ЭтаФорма.Шахматка.НайтиСтроки(ОтборСтрок);
		
		Если СтрокиИзменить.Количество() Тогда
			
			ТекСтрока = СтрокиИзменить[0];
			
			Если СтруктураРезультата.ИмяКолонкиСклада <> Неопределено Тогда
				
				ТекСтрока[СтруктураРезультата.ИмяКолонкиСклада] = Истина;
				
			Иначе
				
				Для каждого ТекКолонка Из Элементы.Шахматка.ПодчиненныеЭлементы Цикл
				
					Если Лев(ТекКолонка.Имя, 1) = "_" Тогда
					
						ТекСтрока[ТекКолонка.Имя] = Истина;
					
					КонецЕсли;
				
				КонецЦикла;
				
			КонецЕсли;
			
		КонецЕсли;
		
		СкладПредыдущееЗначение = Неопределено;
		
	Иначе
		
		Отказ = Истина;
		
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = СтруктураРезультата.Сообщение;
		Сообщение.Сообщить();
		
	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиентеНаСервереБезКонтекста
Функция ПолучитьИмяКолонкиСкладаПоСсылкеСклада(СкладСсылка)
	
	Если ЗначениеЗаполнено(СкладСсылка) Тогда
		
		Возврат СтрШаблон("_%1", СтрЗаменить(СкладСсылка.УникальныйИдентификатор(), "-", "_"))
		
	Иначе
		
		Возврат Неопределено;

	КонецЕсли;

КонецФункции // ПолучитьИмяКолонкиСкладаПоСсылкеСклада()

&НаКлиентеНаСервереБезКонтекста
Функция ПолучитьПустуюСтруктуруВозвратаПриОбработкеИзмененияСкладов()

	Возврат Новый Структура("Успех,Сообщение,НовыйСписокСкладов,ИмяКолонкиСклада,Склад", Истина, "")

КонецФункции // ПолучитьПустуюСтруктуруВозвратаПриОбработкеИзмененияСкладов()

&НаСервереБезКонтекста
Функция ОбработатьИзменениеФлагаШахматкиПоМенеджеруИИмениКолонкиСклада(Менеджер, ИмяКолонкиСклада, ФлагВключен)

	СтруктураВозврата = ПолучитьПустуюСтруктуруВозвратаПриОбработкеИзмененияСкладов();
	
	УИДСклада = Новый УникальныйИдентификатор(СтрЗаменить(Прав(ИмяКолонкиСклада, 36), "_", "-"));
	
	СкладСсылка = Справочники.Склады.ПолучитьСсылку(УИДСклада);
	СтруктураВозврата.Вставить("Склад", СкладСсылка);
	
	СтруктураРезультата = ОбработатьИзменениеФлагаШахматкиПоМенеджеруИСкладу(Менеджер, СкладСсылка, ФлагВключен);
	
	ЗаполнитьЗначенияСвойств(СтруктураВозврата, СтруктураРезультата,, "Склад");
	
	Возврат СтруктураВозврата;

КонецФункции

&НаСервереБезКонтекста
Функция ОбработатьИзменениеФлагаШахматкиПоМенеджеруИСкладу(Менеджер, СкладСсылка, ФлагВключен)

	СтруктураВозврата = ПолучитьПустуюСтруктуруВозвратаПриОбработкеИзмененияСкладов();
	
	ИмяКолонкиСклада = ПолучитьИмяКолонкиСкладаПоСсылкеСклада(СкладСсылка);
	
	СтруктураВозврата.Вставить("ИмяКолонкиСклада", ИмяКолонкиСклада);
	
	СтруктураРезультата = ОбработатьИзменениеФлагаШахматки(Менеджер, СкладСсылка, ФлагВключен);
	
	ЗаполнитьЗначенияСвойств(СтруктураВозврата, СтруктураРезультата,, "ИмяКолонкиСклада");
	
	Возврат СтруктураВозврата;

КонецФункции

&НаСервереБезКонтекста
Функция ОбработатьИзменениеФлагаШахматки(Менеджер, СкладСсылка, ФлагВключен)
	
	Перем Запрос, МенеджерЗаписи, НаборЗаписей, ТаблицаРезультата, СтруктураВозврата;

	СтруктураВозврата = ПолучитьПустуюСтруктуруВозвратаПриОбработкеИзмененияСкладов();
	
	МенеджерЗаписи = РегистрыСведений.ПраваМенеджеровПоПродажамНаСклады.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Менеджер = Менеджер;
	МенеджерЗаписи.Склад = СкладСсылка;
	МенеджерЗаписи.Прочитать();
	
	Если Не ФлагВключен И МенеджерЗаписи.Выбран() Тогда
		
		// Была доступность по складам и для одного из них отлючили флаг
		
		Попытка
			МенеджерЗаписи.Удалить();
			Если Не ЗначениеЗаполнено(СкладСсылка) Тогда
				СтруктураВозврата.Вставить("НовыйСписокСкладов", Новый Массив);
			КонецЕсли;
		Исключение
			СтруктураВозврата.Успех = Ложь;
			СтруктураВозврата.Сообщение = ОписаниеОшибки();
		КонецПопытки;
		
	ИначеЕсли Не ФлагВключен Тогда
		
		// Была включена доступность для всех складов и теперь убрали флаг с одного и них
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("Менеджер", Менеджер);
		Запрос.УстановитьПараметр("Склад", СкладСсылка);
		Запрос.Текст =
		"ВЫБРАТЬ
		|	Склады.Ссылка КАК Склад,
		|	&Менеджер КАК Менеджер
		|ИЗ
		|	Справочник.Склады КАК Склады
		|ГДЕ
		|	Склады.Ссылка <> &Склад";
		
		ТаблицаРезультата = Запрос.Выполнить().Выгрузить();
		
		НаборЗаписей = РегистрыСведений.ПраваМенеджеровПоПродажамНаСклады.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.Менеджер.Значение = Менеджер;
		НаборЗаписей.Отбор.Менеджер.Использование = Истина;
		
		НаборЗаписей.Загрузить(ТаблицаРезультата);
		
		Попытка
			НаборЗаписей.Записать(Истина);
			СтруктураВозврата.Вставить("НовыйСписокСкладов", ТаблицаРезультата.ВыгрузитьКолонку("Склад"));
		Исключение
			СтруктураВозврата.Успех = Ложь;
			СтруктураВозврата.Сообщение = ОписаниеОшибки();
		КонецПопытки;
		
	Иначе
		
		// Если включили для позиции флаг, просто добавляем информацию
		
		МенеджерЗаписи.Менеджер = Менеджер;
		МенеджерЗаписи.Склад = СкладСсылка;
		
		Попытка
			МенеджерЗаписи.Записать(Истина);
		Исключение
			СтруктураВозврата.Успех = Ложь;
			СтруктураВозврата.Сообщение = ОписаниеОшибки();
		КонецПопытки;
		
	КонецЕсли;
	
	Возврат СтруктураВозврата;

КонецФункции // ОбработатьИзменениеФлагаШахматки()

#КонецОбласти
