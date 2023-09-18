use godot::{prelude::*, engine::{Image, image::Format}};
use qrcode::QrCode;

struct GodotQRLib;

#[gdextension]
unsafe impl ExtensionLibrary for GodotQRLib {}

#[derive(GodotClass)]
#[class]
pub struct QR {
    #[base]
    base: Base<RefCounted>
}

#[godot_api]
impl RefCountedVirtual for QR {
    fn init(base: Base<RefCounted>) -> Self {
        Self {
            base
        }
    }
}

#[godot_api]
impl QR {
    #[func]
    fn get_image(&mut self, string: GodotString) -> Gd<Image> {
        let padding = 1;

        let code = QrCode::new(string.to_string()).unwrap();
        let size: i32 = code.width().try_into().unwrap();
        let mut image = Image::create(size + padding*2 , size + padding*2, false, Format::FORMAT_RGB8).unwrap();
        image.fill(Color::WHITE);

        let mut index: i32 = 0;
        for color in code.to_colors() {
            if color == qrcode::Color::Dark {
                let x = padding + index % size;
                let y = padding + index / size;
                image.fill_rect(Rect2i::new(Vector2i::new(x, y), Vector2i::ONE), Color::BLACK);
            }
            index += 1;
        }

        return image;
    }
}