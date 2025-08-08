require_relative "base_report_pdf"

class ProductReportPdf < BaseReportPdf
  def initialize(products, user)
    super(user) # Pasa el usuario a la clase padre (BaseReportPdf)
    @products = products
  end

  # Sobrescribimos el método `render` para usar el `render_report` del padre
  def render
    # 1. Build the document content using the base class helper with an English title.
    render_report(title: "Product Stock Report") do
        table_content
        move_down 20
      end
    # 2. Llama al `render` original de Prawn para generar el PDF y devolverlo.
    super
  end

  private

  # La lógica para crear la tabla específica de este reporte
  def table_content
    col_widths = [
      bounds.width * 0.08, # Columna ID
      bounds.width * 0.45, # Columna nombre del Producto
      bounds.width * 0.12, # Columna Precio
      bounds.width * 0.20, # Columna Categoria
      bounds.width * 0.15  # Columna Cantidad en Stock
    ]
    table(table_data, header: true, width: bounds.width, column_widths: col_widths) do
      # Estilos para la tabla
      row(0).font_style = :bold
      row(0).background_color = "DDDDDD"
      self.row_colors = [ "FFFFFF", "F0F0F0" ]
      self.cell_style = { padding: [ 6, 8, 6, 8 ], border_width: 0.5, border_color: "AAAAAA" }
    end
  end

  def table_data
    # Table header in English
    [ [ "ID", "Name", "Price", "Category", "Stock" ] ] +
      # Filas de datos
      @products.map do |product|
        [
          product.id,
          product.name,
          format_currency(product.price), # Usamos el helper de
          product.category.name,
          product.stock
        ]
      end
  end
end
