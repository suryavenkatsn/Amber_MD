import os
from pptx import Presentation
from pptx.util import Inches, Pt

def create_single_slide_ppt(images_folder, output_ppt):
    # Create a presentation object with 16:9 slide size
    prs = Presentation()
    prs.slide_width = Inches(16)
    prs.slide_height = Inches(9)

    # Get a list of image files in the folder
    image_files = [f for f in os.listdir(images_folder) if f.lower().endswith(('.png', '.jpg', '.jpeg', '.gif', '.bmp', '.tiff'))]

    # Create a single slide
    slide_layout = prs.slide_layouts[5]  # Use a blank slide layout
    slide = prs.slides.add_slide(slide_layout)

    # Calculate the number of columns and rows
    num_columns = 3
    num_rows = 2

    # Calculate the width and height of each image based on the number of columns and rows
    image_width = prs.slide_width / num_columns
    image_height = prs.slide_height / num_rows

    # Set the initial position for placing images and captions
    left = 0
    top = 0
    row_spacing = Inches(0.2)  # Adjust the spacing between rows

    # Add each image to the slide with captions
    for image_file in image_files:
        image_path = os.path.join(images_folder, image_file)

        # Add the image to the slide with 4:3 aspect ratio
        picture = slide.shapes.add_picture(image_path, left, top, height=Inches(3), width=Inches(4))

        # Extract the file name without extension as a caption
        caption = os.path.splitext(image_file)[0]

        # Add a text box for the caption centered below the image
        textbox = slide.shapes.add_textbox(left, top + Inches(3), width=Inches(4), height=Inches(0.5))
        text_frame = textbox.text_frame
        text_frame.text = caption.strip()  # Remove leading and trailing spaces
        p = text_frame.paragraphs[0]
        p.alignment = 1  # Center alignment

        # Update the position for the next image
        left += image_width

        # Move to the next row if the current row is filled
        if left >= prs.slide_width:
            left = 0
            top += image_height + row_spacing  # Add row spacing

    # Save the presentation
    prs.save(output_ppt)

if __name__ == "__main__":
    current_folder = os.getcwd()  # Get the current working directory
    output_ppt_file = "traj_analysis.pptx"

    create_single_slide_ppt(current_folder, output_ppt_file)
    print(f"Presentation created: {output_ppt_file}")
