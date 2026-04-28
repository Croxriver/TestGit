import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../widgets/todo_item.dart';
import 'add_todo_screen.dart';
import 'theme_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final List<Todo> _todos = [];
  late TabController _tabController;
  String _searchQuery = '';
  int _bottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _addSampleTodos();
  }

  void _addSampleTodos() {
    _todos.addAll([
      Todo(
        id: '1',
        title: 'Flutter 앱 개발 완료하기',
        description: '기본 Todo 앱 구조 완성',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        priority: Priority.high,
      ),
      Todo(
        id: '2',
        title: '점심 먹기',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        priority: Priority.low,
        isCompleted: true,
      ),
      Todo(
        id: '3',
        title: 'Flutter 문서 읽기',
        description: 'State management 공부',
        createdAt: DateTime.now(),
        priority: Priority.medium,
      ),
    ]);
  }

  List<Todo> get _filteredTodos {
    List<Todo> todos = _todos;
    if (_searchQuery.isNotEmpty) {
      todos = todos
          .where((t) =>
              t.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return todos;
  }

  List<Todo> get _pendingTodos =>
      _filteredTodos.where((t) => !t.isCompleted).toList();

  List<Todo> get _completedTodos =>
      _filteredTodos.where((t) => t.isCompleted).toList();

  void _toggleTodo(String id) {
    setState(() {
      final index = _todos.indexWhere((t) => t.id == id);
      if (index != -1) {
        _todos[index] = _todos[index].copyWith(
          isCompleted: !_todos[index].isCompleted,
        );
      }
    });
  }

  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((t) => t.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('할 일이 삭제되었습니다'),
        action: SnackBarAction(
          label: '실행취소',
          onPressed: () {},
        ),
      ),
    );
  }

  Future<void> _addTodo() async {
    final result = await Navigator.push<Todo>(
      context,
      MaterialPageRoute(builder: (_) => const AddTodoScreen()),
    );
    if (result != null) {
      setState(() => _todos.add(result));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _bottomNavIndex,
        children: [
          _HomeTab(
            todos: _todos,
            filteredTodos: _filteredTodos,
            pendingTodos: _pendingTodos,
            completedTodos: _completedTodos,
            tabController: _tabController,
            searchQuery: _searchQuery,
            onSearchChanged: (v) => setState(() => _searchQuery = v),
            onToggle: _toggleTodo,
            onDelete: _deleteTodo,
          ),
          _StatisticsTab(todos: _todos),
          _CalendarTab(todos: _todos),
          const _MoreTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _bottomNavIndex,
        onDestinationSelected: (index) =>
            setState(() => _bottomNavIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: '통계',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: '캘린더',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more_horiz),
            label: '더보기',
          ),
        ],
      ),
      floatingActionButton: _bottomNavIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _addTodo,
              icon: const Icon(Icons.add),
              label: const Text('새 할 일'),
            )
          : null,
    );
  }
}

// ── 홈 탭 ──────────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  final List<Todo> todos;
  final List<Todo> filteredTodos;
  final List<Todo> pendingTodos;
  final List<Todo> completedTodos;
  final TabController tabController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final void Function(String) onToggle;
  final void Function(String) onDelete;

  const _HomeTab({
    required this.todos,
    required this.filteredTodos,
    required this.pendingTodos,
    required this.completedTodos,
    required this.tabController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedCount = todos.where((t) => t.isCompleted).length;
    final total = todos.length;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          expandedHeight: 180,
          pinned: true,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          flexibleSpace: FlexibleSpaceBar(
            background: Padding(
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '나의 할 일',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    total == 0
                        ? '할 일을 추가해 보세요!'
                        : '$total개 중 $completedCount개 완료',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimary.withOpacity(0.8),
                    ),
                  ),
                  if (total > 0) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: total > 0 ? completedCount / total : 0,
                        backgroundColor:
                            theme.colorScheme.onPrimary.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.onPrimary,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: ColoredBox(
              color: theme.colorScheme.primary,
              child: TabBar(
                controller: tabController,
                labelColor: theme.colorScheme.onPrimary,
                unselectedLabelColor:
                    theme.colorScheme.onPrimary.withOpacity(0.6),
                indicatorColor: theme.colorScheme.onPrimary,
                tabs: [
                  Tab(text: '전체 (${filteredTodos.length})'),
                  Tab(text: '진행 중 (${pendingTodos.length})'),
                  Tab(text: '완료 (${completedTodos.length})'),
                ],
              ),
            ),
          ),
        ),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SearchBar(
              hintText: '할 일 검색...',
              leading: const Icon(Icons.search),
              onChanged: onSearchChanged,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                _TodoList(
                  todos: filteredTodos,
                  onToggle: onToggle,
                  onDelete: onDelete,
                ),
                _TodoList(
                  todos: pendingTodos,
                  onToggle: onToggle,
                  onDelete: onDelete,
                ),
                _TodoList(
                  todos: completedTodos,
                  onToggle: onToggle,
                  onDelete: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 통계 탭 ────────────────────────────────────────────────────────────────

class _StatisticsTab extends StatelessWidget {
  final List<Todo> todos;

  const _StatisticsTab({required this.todos});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = todos.length;
    final completed = todos.where((t) => t.isCompleted).length;
    final pending = total - completed;
    final rate = total > 0 ? completed / total : 0.0;

    final highCount = todos.where((t) => t.priority == Priority.high).length;
    final medCount = todos.where((t) => t.priority == Priority.medium).length;
    final lowCount = todos.where((t) => t.priority == Priority.low).length;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          title: Text(
            '통계',
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _SectionTitle('전체 현황'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: '전체',
                      value: '$total',
                      icon: Icons.list_alt,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: '완료',
                      value: '$completed',
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: '진행 중',
                      value: '$pending',
                      icon: Icons.pending,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SectionTitle('완료율'),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(rate * 100).toStringAsFixed(1)}%',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            '$completed / $total',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: rate,
                          minHeight: 12,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _SectionTitle('우선순위별 현황'),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    _PriorityRow(
                      label: '높음',
                      count: highCount,
                      total: total,
                      color: Priority.high.color,
                    ),
                    const Divider(height: 1),
                    _PriorityRow(
                      label: '보통',
                      count: medCount,
                      total: total,
                      color: Priority.medium.color,
                    ),
                    const Divider(height: 1),
                    _PriorityRow(
                      label: '낮음',
                      count: lowCount,
                      total: total,
                      color: Priority.low.color,
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _PriorityRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(label, style: theme.textTheme.bodyMedium),
          const Spacer(),
          SizedBox(
            width: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 24,
            child: Text(
              '$count',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 캘린더 탭 ──────────────────────────────────────────────────────────────

class _CalendarTab extends StatefulWidget {
  final List<Todo> todos;

  const _CalendarTab({required this.todos});

  @override
  State<_CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<_CalendarTab> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay;

  List<Todo> get _todosOnSelected {
    if (_selectedDay == null) return [];
    return widget.todos.where((t) {
      final d = t.createdAt;
      return d.year == _selectedDay!.year &&
          d.month == _selectedDay!.month &&
          d.day == _selectedDay!.day;
    }).toList();
  }

  void _prevMonth() => setState(() {
        _focusedMonth =
            DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
      });

  void _nextMonth() => setState(() {
        _focusedMonth =
            DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
      });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // 0=Sun

    final todosByDay = <int, List<Todo>>{};
    for (final t in widget.todos) {
      if (t.createdAt.year == _focusedMonth.year &&
          t.createdAt.month == _focusedMonth.month) {
        todosByDay.putIfAbsent(t.createdAt.day, () => []).add(t);
      }
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          title: Text(
            '캘린더',
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _prevMonth,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text(
                        '${_focusedMonth.year}년 ${_focusedMonth.month}월',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: _nextMonth,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: ['일', '월', '화', '수', '목', '금', '토']
                        .map((d) => Expanded(
                              child: Center(
                                child: Text(
                                  d,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.outline,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 4),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      childAspectRatio: 1,
                    ),
                    itemCount: startWeekday + daysInMonth,
                    itemBuilder: (context, index) {
                      if (index < startWeekday) return const SizedBox();
                      final day = index - startWeekday + 1;
                      final date = DateTime(
                          _focusedMonth.year, _focusedMonth.month, day);
                      final isToday = date.year == now.year &&
                          date.month == now.month &&
                          date.day == now.day;
                      final isSelected = _selectedDay != null &&
                          date.year == _selectedDay!.year &&
                          date.month == _selectedDay!.month &&
                          date.day == _selectedDay!.day;
                      final hasTodos = todosByDay.containsKey(day);

                      return GestureDetector(
                        onTap: () => setState(() => _selectedDay = date),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : isToday
                                    ? theme.colorScheme.primaryContainer
                                    : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$day',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isSelected
                                      ? theme.colorScheme.onPrimary
                                      : isToday
                                          ? theme.colorScheme.primary
                                          : null,
                                  fontWeight:
                                      isToday ? FontWeight.bold : null,
                                ),
                              ),
                              if (hasTodos)
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_selectedDay != null)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  '${_selectedDay!.month}월 ${_selectedDay!.day}일 할 일',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (_todosOnSelected.isEmpty)
                  Text(
                    '이 날의 할 일이 없습니다',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  )
                else
                  ..._todosOnSelected.map(
                    (t) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        t.isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: t.isCompleted ? Colors.green : null,
                      ),
                      title: Text(
                        t.title,
                        style: TextStyle(
                          decoration: t.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: t.isCompleted
                              ? theme.colorScheme.outline
                              : null,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: t.priority.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          t.priority.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: t.priority.color,
                          ),
                        ),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
      ],
    );
  }
}

// ── 더보기 탭 ──────────────────────────────────────────────────────────────

class _MoreTab extends StatelessWidget {
  const _MoreTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          title: Text(
            '더보기',
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 24),
              CircleAvatar(
                radius: 40,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '사용자',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'user@example.com',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 24),
              _MoreSection(
                title: '설정',
                items: [
                  const _MoreItem(
                    icon: Icons.notifications_outlined,
                    label: '알림 설정',
                  ),
                  _MoreItem(
                    icon: Icons.palette_outlined,
                    label: '테마',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ThemeScreen()),
                    ),
                  ),
                  const _MoreItem(
                    icon: Icons.language_outlined,
                    label: '언어',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _MoreSection(
                title: '앱 정보',
                items: const [
                  _MoreItem(
                    icon: Icons.info_outline,
                    label: '앱 버전',
                    trailing: '1.0.0',
                  ),
                  _MoreItem(
                    icon: Icons.privacy_tip_outlined,
                    label: '개인정보 처리방침',
                  ),
                  _MoreItem(
                    icon: Icons.description_outlined,
                    label: '이용약관',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _MoreSection(
                title: '계정',
                items: const [
                  _MoreItem(
                    icon: Icons.logout,
                    label: '로그아웃',
                    isDestructive: true,
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
}

class _MoreSection extends StatelessWidget {
  final String title;
  final List<_MoreItem> items;

  const _MoreSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.outline,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: List.generate(items.length, (i) => Column(
              children: [
                items[i],
                if (i < items.length - 1) const Divider(height: 1),
              ],
            )),
          ),
        ),
      ],
    );
  }
}

class _MoreItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _MoreItem({
    required this.icon,
    required this.label,
    this.trailing,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive ? theme.colorScheme.error : null;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      trailing: trailing != null
          ? Text(
              trailing!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            )
          : (!isDestructive
              ? Icon(Icons.chevron_right, color: theme.colorScheme.outline)
              : null),
      onTap: onTap,
    );
  }
}

// ── 공통 위젯 ──────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _TodoList extends StatelessWidget {
  final List<Todo> todos;
  final void Function(String) onToggle;
  final void Function(String) onDelete;

  const _TodoList({
    required this.todos,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '할 일이 없습니다',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemCount: todos.length,
      itemBuilder: (context, index) => TodoItem(
        todo: todos[index],
        onToggle: onToggle,
        onDelete: onDelete,
      ),
    );
  }
}
