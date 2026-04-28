import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../widgets/todo_item.dart';
import 'add_todo_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final List<Todo> _todos = [];
  late TabController _tabController;
  String _searchQuery = '';

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
    final theme = Theme.of(context);
    final completedCount = _todos.where((t) => t.isCompleted).length;
    final total = _todos.length;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: NestedScrollView(
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
                  controller: _tabController,
                  labelColor: theme.colorScheme.onPrimary,
                  unselectedLabelColor:
                      theme.colorScheme.onPrimary.withOpacity(0.6),
                  indicatorColor: theme.colorScheme.onPrimary,
                  tabs: [
                    Tab(text: '전체 (${_filteredTodos.length})'),
                    Tab(text: '진행 중 (${_pendingTodos.length})'),
                    Tab(text: '완료 (${_completedTodos.length})'),
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
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _TodoList(
                    todos: _filteredTodos,
                    onToggle: _toggleTodo,
                    onDelete: _deleteTodo,
                  ),
                  _TodoList(
                    todos: _pendingTodos,
                    onToggle: _toggleTodo,
                    onDelete: _deleteTodo,
                  ),
                  _TodoList(
                    todos: _completedTodos,
                    onToggle: _toggleTodo,
                    onDelete: _deleteTodo,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTodo,
        icon: const Icon(Icons.add),
        label: const Text('새 할 일'),
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
