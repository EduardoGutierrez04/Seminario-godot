extends CharacterBody3D

# Estados de la máquina de estados finitos (FSM).
enum State { IDLE, WALK, JUMP }
var current_state: State = State.IDLE

@export var move_speed: float = 6.0
@export var jump_velocity: float = 5.5
@export var gravity: float = 12.0
@export var visual_turn_speed: float = 10.0

var movement_direction: Vector3 = Vector3.ZERO

@onready var camera_pivot: Node3D = $CameraPivot
@onready var spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var visual_root: Node3D = $VisualRoot
@onready var state_label: Label = $HUD/StateLabel

func _ready() -> void:
    # El cursor se captura para que el movimiento del mouse gire la cámara.
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    _change_state(State.IDLE)

func _physics_process(delta: float) -> void:
    # 1. Leer controles y calcular una dirección horizontal relativa a la cámara.
    var input_vector: Vector2 = Input.get_vector(
        "move_left", "move_right", "move_forward", "move_back"
    )

    var camera_right: Vector3 = camera_pivot.global_basis.x
    var camera_back: Vector3 = camera_pivot.global_basis.z
    camera_right.y = 0.0
    camera_back.y = 0.0
    camera_right = camera_right.normalized()
    camera_back = camera_back.normalized()

    movement_direction = camera_right * input_vector.x + camera_back * input_vector.y
    if movement_direction.length() > 1.0:
        movement_direction = movement_direction.normalized()

    # 2. La velocidad horizontal está expresada en unidades por segundo.
    # No se multiplica por delta aquí: move_and_slide() aplica el paso físico.
    velocity.x = movement_direction.x * move_speed
    velocity.z = movement_direction.z * move_speed

    # 3. La gravedad cambia la velocidad vertical, por eso sí usa delta.
    if not is_on_floor():
        velocity.y -= gravity * delta
    elif velocity.y < 0.0:
        velocity.y = 0.0

    # Sólo se puede iniciar un salto mientras se está en el suelo.
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity

    # Mueve el cuerpo y resuelve las colisiones. No multiplicar velocity por delta.
    move_and_slide()

    # Actualizar la FSM después de resolver el movimiento físico.
    if not is_on_floor():
        _change_state(State.JUMP)
    elif movement_direction.length() > 0.1:
        _change_state(State.WALK)
    else:
        _change_state(State.IDLE)

func _process(delta: float) -> void:
    # Actualización visual separada de la física. delta controla la interpolación.
    if movement_direction.length() > 0.1:
        var target_angle: float = atan2(-movement_direction.x, -movement_direction.z)
        visual_root.rotation.y = lerp_angle(
            visual_root.rotation.y,
            target_angle,
            min(visual_turn_speed * delta, 1.0)
        )

func _change_state(new_state: State) -> void:
    if current_state == new_state:
        return

    current_state = new_state
    var state_name: String = "IDLE"
    match current_state:
        State.IDLE:
            state_name = "IDLE"
        State.WALK:
            state_name = "WALK"
        State.JUMP:
            state_name = "JUMP"

    state_label.text = "Estado: " + state_name
    print("Estado actual: ", state_name)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        camera_pivot.rotate_y(-event.relative.x * 0.003)
        spring_arm.rotation.x -= event.relative.y * 0.003
        spring_arm.rotation.x = clamp(spring_arm.rotation.x, -0.8, 0.35)

    if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        else:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

    if event is InputEventMouseButton and event.pressed and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
