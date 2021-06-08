require_relative 'helpers.rb'

run_sql("
  INSERT INTO reviews (
    model, 
    rating, 
    image_url, 
    review,
    user_id
    ) values (
      'ibanez s series',
      '5',
      'https://andertons-productimages.imgix.net/13293-EGEN18TVF_super.jpg?w=768&h=768&fit=fill&bg=FFFFFF&auto=format&ixlib=imgixjs-3.3.2',
      'Lorem ipsum dolor sit amet consectetur adipisicing elit. Aperiam incidunt commodi velit accusamus eligendi ab vero. Fugit illum nostrum possimus nihil autem, optio ducimus labore quaerat voluptatibus rem odit voluptatum.',
      '1'
    );
");