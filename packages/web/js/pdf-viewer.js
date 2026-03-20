// Configuración de PDF.js
pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.16.105/pdf.worker.min.js';
const PDFViewer = {
    currentPdf: null,
    currentPage: 1,
    totalPages: 1,
    async show(pdfBlob) {
        const container = document.querySelector('.pdf-viewer');
        container.innerHTML = '<div class="pdf-loading">Cargando PDF...</div>';
        try {
            const arrayBuffer = await pdfBlob.arrayBuffer();
            const pdf = await pdfjsLib.getDocument({ data: arrayBuffer }).promise;
            this.currentPdf = pdf;
            this.totalPages = pdf.numPages;
            // Crear controles de navegación
            const controls = `
                <div class="pdf-controls">
                    <button onclick="PDFViewer.prevPage()" id="pdf-prev"><i class="fas fa-chevron-left"></i></button>
                    <span>Página <span id="pdf-current-page">1</span> de ${this.totalPages}</span>
                    <button onclick="PDFViewer.nextPage()" id="pdf-next"><i class="fas fa-chevron-right"></i></button>
                </div>
            `;
            container.innerHTML = controls + '<div id="pdf-canvas-container" style="text-align: center;"></div>';
            await this.renderPage(1);
        } catch (error) {
            container.innerHTML = `<div class="pdf-error">Error al cargar PDF: ${error.message}</div>`;
        }
    },
    async renderPage(pageNumber) {
        if (!this.currentPdf) return;
        const page = await this.currentPdf.getPage(pageNumber);
        const container = document.getElementById('pdf-canvas-container');
        // Calcular escala para que quepa en el contenedor
        const containerWidth = container.clientWidth || 800;
        const viewport = page.getViewport({ scale: 1 });
        const scale = containerWidth / viewport.width;
        const scaledViewport = page.getViewport({ scale });
        // Crear canvas
        const canvas = document.createElement('canvas');
        const context = canvas.getContext('2d');
        canvas.width = scaledViewport.width;
        canvas.height = scaledViewport.height;
        container.innerHTML = '';
        container.appendChild(canvas);
        // Renderizar página
        const renderContext = {
            canvasContext: context,
            viewport: scaledViewport
        };
        await page.render(renderContext).promise;
        // Actualizar número de página
        document.getElementById('pdf-current-page').textContent = pageNumber;
        this.currentPage = pageNumber;
        // Actualizar botones
        document.getElementById('pdf-prev').disabled = pageNumber === 1;
        document.getElementById('pdf-next').disabled = pageNumber === this.totalPages;
    },
    async prevPage() {
        if (this.currentPage > 1) {
            await this.renderPage(this.currentPage - 1);
        }
    },
    async nextPage() {
        if (this.currentPage < this.totalPages) {
            await this.renderPage(this.currentPage + 1);
        }
    }
};
